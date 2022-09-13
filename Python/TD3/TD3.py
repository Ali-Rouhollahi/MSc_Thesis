import numpy as np
import copy
import torch
import torch.nn as nn
import torch.nn.functional as func
import matplotlib.pyplot as plt
from  datetime import datetime


class Actor(nn.Module):
    def __init__(self,state_dim,action_dim,min_actions,max_actions):
        super(Actor, self).__init__()

        self.l1 = nn.Linear(state_dim, 256)
        self.l2 = nn.Linear(256, 256)
        self.l3 = nn.Linear(256,action_dim)

        self.min_actions = np.array(min_actions)
        self.max_actions = np.array(max_actions)

    def Forward(self,states):
        a = func.relu(self.l1(states))
        a = func.relu(self.l2(a))
        a = torch.tanh(self.l3(a))
        #span action to its max-min 
        a = a.detach().numpy()
        a = a * (self.max_actions-self.min_actions)/2+(self.max_actions+self.min_actions)/2
        a = torch.tensor(a)
        return a

class Critic(nn.Module):
    def __init__(self,state_dim,action_dim):
        super(Critic,self).__init__()

        #Q1 Architecture
        self.l1=nn.Linear(state_dim+action_dim, 256)
        self.l2=nn.Linear(256, 256)
        self.l3=nn.Linear(256,1)

        #Q2 Architecture
        self.l4=nn.Linear(state_dim+action_dim, 256)
        self.l5=nn.Linear(256, 256)
        self.l6=nn.Linear(256,1)


    def Forward(self,states,actions):

        state_action = torch.cat([states,actions],1)
        state_action = state_action.type(torch.FloatTensor)

        q1 = func.relu(self.l1(state_action))
        q1 = func.relu(self.l2(q1))
        q1 = self.l3(q1)

        q2 = func.relu(self.l4(state_action))
        q2 = func.relu(self.l5(q2))
        q2 = self.l6(q2)

        return q1,q2


    def Q1(self,states,actions):
        state_action=torch.cat([states,actions],1)
        state_action=state_action.type(torch.FloatTensor)

        q1 = func.relu(self.l1(state_action))
        q1 = func.relu(self.l2(q1))
        q1 = self.l3(q1)

        return q1


class TD3(object): #why inherit from 'object' : https://stackoverflow.com/questions/4015417/why-do-python-classes-inherit-object
    def __init__(self,environment,state_dim,action_dim,discount_factor=1,tau=0.005,policy_noise=0.2,noise_clip=0.5,policy_freq=2):

        self.env = environment
        self.min_actions = self.env.min_actions
        self.max_actions = self.env.max_actions
        self.d_t = datetime.today().strftime("%Y-%m-%d-%H-%M")
        
        self.actor = Actor(state_dim, action_dim, self.min_actions, self.max_actions)
        self.actor_target = copy.deepcopy(self.actor)
        self.actor_optimizer = torch.optim.Adam(self.actor.parameters(),lr=4e-4)

        self.critic = Critic(state_dim, action_dim)
        self.critic_target = copy.deepcopy(self.critic)
        self.critic_optimizer = torch.optim.Adam(self.critic.parameters(),lr=4e-4)


        self.discount_factor = discount_factor
        self.tau = tau
        self.policy_noise = policy_noise * 0.5 * (np.array(self.max_actions)-np.array(self.min_actions))
        self.noise_clip = noise_clip * 0.5 * (np.array(self.max_actions)-np.array(self.min_actions))
        self.policy_freq = policy_freq

        self.total_it = 0

        self.avg_reward = []
        self.actor_loss = []
        self.critic_loss = []

    
    def select_action(self,state):
        state1 = torch.FloatTensor(state.reshape(1,-1))
        return self.actor.Forward(state1)

    def train(self,replay_buffer,batch_size=256):
        self.total_it = self.total_it + 1

        #sample replay_buffer
        state, action, next_state, reward, not_done = replay_buffer.sample(batch_size)

        with torch.no_grad():
			# Select action according to policy and add clipped noise
            noise = np.clip(torch.randn_like(action)*self.policy_noise, -self.noise_clip, self.noise_clip)

            a = self.actor_target.Forward(next_state)+noise
            next_action = np.clip(a, self.min_actions, self.max_actions)

            #compute the target Q value
            target_Q1, target_Q2 = self.critic_target.Forward(next_state,next_action)
            target_Q = torch.min(target_Q1,target_Q2)

            new_shape = (len(not_done), 1)
            not_done = not_done.view(new_shape)
            reward = reward.view(new_shape)

            target_Q = reward + not_done * self.discount_factor * target_Q


        #Get current Q estimates
        current_Q1, current_Q2 = self.critic.Forward(state,action)

        #compute critic loss
        critic_loss = func.mse_loss(current_Q1, target_Q)+func.mse_loss(current_Q2, target_Q)
        
        #optimize critic loss
        self.critic_optimizer.zero_grad()
        critic_loss.backward()
        self.critic_optimizer.step()

        #END TRAIN
        flag = False
        #Delayed policy updates
        if self.total_it % self.policy_freq == 0:

            #compute actor loss
            actor_loss = self.critic.Q1(state,self.actor.Forward(state)).mean()

            #optimize the actor
            self.actor_optimizer.zero_grad()
            actor_loss.backward()
            self.actor_optimizer.step()

            #Update the frozen target models
            for param, target_param in zip(self.critic.parameters(), self.critic_target.parameters()):
                target_param.data.copy_(self.tau * param.data + (1 - self.tau) * target_param.data)
            for param, target_param in zip(self.actor.parameters(), self.actor_target.parameters()):
                target_param.data.copy_(self.tau * param.data + (1 - self.tau) * target_param.data)

            print(f"actor loss: {actor_loss}")#\n  actor param :{self.actor.parameters().data}\n actor target param :{self.actor_target.parameters().data}")
            self.actor_loss.append(actor_loss.detach().numpy())
            if(np.abs(actor_loss.detach().numpy()) < 1):
                flag = True
        
        print(f"critic loss:{critic_loss}")#\n critic param :{self.critic.parameters().data}\n critic target param :{self.critic_target.parameters().data}")
        self.critic_loss.append(critic_loss.detach().numpy())

        return flag

    def save(self,filename):
        torch.save(self.critic.state_dict(), filename + "_critic")
        torch.save(self.critic_optimizer.state_dict(), filename + "_critic_optimizer")

        torch.save(self.actor.state_dict(), filename + "_actor")
        torch.save(self.actor_optimizer.state_dict(), filename + "_actor_optimizer")

    def save_reward(self):
        
        file_addr = "./data_saved/"+self.d_t+"_avg_rewards.txt"
        file = open(file_addr, "w")
        self.avg_reward = list(np.around(np.array(self.avg_reward),2))
        file.write("avg_reward  %s\n" %(self.avg_reward))
        file.write("actor_loss  %s\n" %(self.actor_loss))
        file.write("critic_loss  %s\n" %(self.critic_loss))
        file.close()

    def load(self, filename):
        self.critic.load_state_dict(torch.load(filename + "_critic"))
        self.critic_optimizer.load_state_dict(torch.load(filename + "_critic_optimizer"))
        self.critic_target = copy.deepcopy(self.critic)

        self.actor.load_state_dict(torch.load(filename + "_actor"))
        self.actor_optimizer.load_state_dict(torch.load(filename + "_actor_optimizer"))
        self.actor_target = copy.deepcopy(self.actor)  

    def load_actor(self, filename):
        self.actor.load_state_dict(torch.load(filename + "_actor"))
        self.actor_optimizer.load_state_dict(torch.load(filename + "_actor_optimizer"))
        self.actor_target = copy.deepcopy(self.actor)  

    def plot_avg_reward(self):
        plt.close()
        plt.figure()
        plt.plot(self.avg_reward,'ro-')
        plt.show()
        
            


