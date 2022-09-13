import numpy as np
from sklearn import preprocessing
from tensorflow.keras.models import  load_model
import joblib
import gym
import math
from gym.utils import seeding

class Environment():
    def __init__(self,TCP_conn,rewards,max_trial,buf_size=1000):

        self.TCP_conn = TCP_conn
        self.rewards = rewards
        self.buf_size = buf_size
        self.max_trial = max_trial

        # self.min_actions=np.array([0.12,0.008,400,0.12,0.008,1000])  #mu_x,var_x,amp_x----mu_y,var_y,amp_y
        # self.max_actions=np.array([0.3,0.015,800,0.3,0.015,1400])
        # bias=(self.max_actions-self.min_actions)/10
        # self.min_actions-=bias
        # self.max_actions+=bias
        # self.min_actions = [-math.pi, -math.pi, -math.pi, 3]#q_FL,q_BR,q_BL,a
        # self.max_actions = [math.pi , math.pi, math.pi, 8]#q_FL,q_BR,q_BL,a
        self.min_actions = [2*math.pi/3, -math.pi/3, 2*math.pi/3, 3]#q_FL,q_BR,q_BL,a
        self.max_actions = [4*math.pi/3, math.pi/3 , 4*math.pi/3, 8]#q_FL,q_BR,q_BL,a

        max_min_state = np.genfromtxt("observation_max_min_leg.csv",delimiter=',')  # q_FR,q_FL,q_BR,q_BL,vx_body,vy_body
        # max_min_state=np.genfromtxt("observation_max_min.csv", delimiter=',')
        self.observation_max = max_min_state[0,:]
        self.observation_min = max_min_state[1,:]


        # #Load AutoEncoder and encoder
        # filepath = 'saved_model.h5'
        # self.autoencoder = load_model(filepath,custom_objects=None,compile=True)
        # filepath = 'saved_encoder.h5'
        # self.encoder= load_model(filepath,custom_objects=None,compile=True)
        # filepath = 'saved_decoder.h5'
        # self.decoder= load_model(filepath,custom_objects=None,compile=True)
        # self.min_max_scaler = joblib.load('min_max_scaler.gz')


        self.observe = {
             'sim_time': 0,
             'o_current':None, # q_FR,q_FL,q_BR,q_BL,vx_body,vy_body
             'o_prev': None,
             'unstable':False
            }


    def receive(self):
        # data=self.TCP_conn.receive_data(self.buf_size) #states 0->5 , unstable 6 , COT*d 7 ,time 8, stride_length 9 , vx 10 , x 11 , tfs 12
        data = self.TCP_conn.receive_data(self.buf_size)# states 0->3 , vx_body 4, vy_body 5, x 6,tilt 7, unstable 8 , COT*d 9,time 10, stride_length 11 , tfs 12

        self.observe['o_prev'] = self.observe['o_current']
        self.observe['o_current'] = data[0:4]
        self.observe['unstable'] = data[8]!=0 #data[6]!=0
        if(data[11] == 0):#(data[9]==0):
            cot = 1000
        else:
            cot = data[9] / data[11]  # data[7]/data[9]
        r = [data[8],cot,data[11],data[4],data[6],data[12],data[7]]#[data[6],cot,data[9],data[10],data[11],data[12]]
        self.rewards.Set_reward_components(r)

        self.observe['sim_time'] = data[10]#data[8]
        
    def autoencode_states(self,observations):
        data_scaled = self.min_max_scaler.transform(observations.reshape(1,-1))
        encoded_states = self.encoder.predict(data_scaled)  # bottleneck representation
        return encoded_states #6 -> 3


    def step(self,action,episode_timesteps,trial):
        data = np.append(action,False)
        # data = np.append(data,int(self.end_sim(trial)))
        data = np.append(data,0)
        self.TCP_conn.send_data(data)
        # if int(self.end_sim(trial)) == 0:
        self.receive()
        reward = self.get_reward()
        ##next_state = self.autoencode_states(np.asarray(self.observe['o_current']))
        next_state = np.asarray(self.observe['o_current'])
        return next_state,reward, self.terminated(episode_timesteps),self.end_sim(trial)

    def sample_action(self):
        action = np.random.uniform(self.min_actions,self.max_actions)
        return action

    def get_reward(self):
        return self.rewards.calculate_reward()
    
    def end_sim(self,trial_num):
        return trial_num == self.max_trial

    def terminated(self,episode_timesteps):
        return episode_timesteps >= 6 or self.observe['unstable']

    def reset(self,replay_buffer,trial):
        if trial <= 1:
            state, action, next_state, reward, not_done = replay_buffer.sample(1)
        else:
            not_done = 0
            while(float(not_done) == 0):
                state, action, next_state, reward, not_done = replay_buffer.reset_sample(1)
            print("Not done:",float(not_done))

        # init_state=np.asarray(self.decoder(np.asarray(state)))
        # init_state=self.min_max_scaler.inverse_transform(init_state.reshape(1,-1))

        init_state = np.random.uniform(self.observation_min, self.observation_max)

        init_action = action
        data = np.append(init_state,init_action)
        data = np.append(data,True)
        data = np.append(data,int(self.end_sim(trial)))

        self.TCP_conn.send_data(data)
        if int(self.end_sim(trial)) == 0:
            data_wait = self.TCP_conn.receive_data(self.buf_size)

            self.observe['sim_time'] =0
            self.observe['o_prev'] = None
            self.observe['o_current'] = init_state

            self.observe['unstable'] = data_wait[8]!=0

        return next_state,reward,self.observe['unstable'],int(self.end_sim(trial))

    def starting_reset(self):
        self.receive()
        self.observe['sim_time'] = 0
        self.observe['o_prev'] = None
        #self.observe['o_current'] = np.random.uniform(self.observation_min,self.observation_max)
        self.observe['unstable'] = False

        ## state = self.autoencode_states(np.asarray(self.observe['o_current']))
        state = np.asarray(self.observe['o_current'])
        return state

    def seed(self,seed=None):
        self.np_random, seed = seeding.np_random(seed)
        return [seed]

