import numpy as np
from Environment import Environment
from TD3 import TD3
from tcp import TCP
from Reward import Reward
from ReplayBuffer import ReplayBuffer
import os
import torch

if not os.path.exists("./results"):
    os.makedirs("./results")

if not os.path.exists("./models"):
    os.makedirs("./models")

if not os.path.exists("./data_saved"):
    os.makedirs("./data_saved")

if not os.path.exists("./replay_buf"):
    os.makedirs("./replay_buf")

file_name = "TD3_Single Leg_Simulink_Simscape"

state_dim = 6 #3 # reduced by autoencoder
action_dim = 4 #6
observation_dim = 6
max_timesteps = 40 


TCP_conn = TCP()
data = TCP_conn.receive_data(130)
max_run_num = int(data[0])
# print("Run Number:",data[0])

for k in range(int(max_run_num)):
    print("Run Number:",k+1)
    rewards = Reward()
    env = Environment(TCP_conn, rewards,max_timesteps)
    env.seed(0)

    policy = TD3(env,state_dim,action_dim)
    replay_buffer = ReplayBuffer(state_dim, action_dim)
    expl_noise = 0#0.01#0.1 # Std of Gaussian exploration noise
    sigma = expl_noise * 0.5 * (np.array(env.max_actions) - np.array(env.min_actions))
    print(sigma)

    # Evaluate untrained policy
    evaluations = 0

    # Set seeds
    seed = 0
    env.seed(seed)
    torch.manual_seed(seed)
    np.random.seed(seed)


    state, done = env.starting_reset(), False #Rcv Init state


    episode_reward = 0
    episode_timesteps = 0
    episode_num = 0

    start_timesteps = 10 #150
    eval_freq = 100
    flag = False

    for t in range(int(max_timesteps)):
        
        episode_timesteps +=1 #trial
        print(episode_timesteps)
        # Select action randomly or according to policy
        if( t < start_timesteps):
            action = env.sample_action()
        else:
            action = np.clip(policy.select_action(state) + np.random.normal(0,sigma,size = action_dim), env.min_actions, env.max_actions)
        
        #Perform action
        next_state,reward,done,end_sim = env.step(action,episode_timesteps,t+1)
        
        #store Data in replay Buffer
        if(episode_timesteps == 10):
            replay_buffer.add(state, action, next_state, reward, False)
        else:
            replay_buffer.add(state, action, next_state, reward, done)

        state = next_state
        episode_reward += reward


        #Train Agent after collecting sufficient data
        if(t >= start_timesteps):
            # flag = policy.train(replay_buffer,batch_size=128)
            flag = policy.train(replay_buffer, batch_size = 10)
        

        if done or end_sim:
            # +1 to account for 0 indexing . 0 on ep_timesteps since it will increment +1 even if done=true
            print(f"Total T:{t+1} Episode Num: {episode_num + 1} Episode T: {episode_timesteps} Reward: {episode_reward:.3f}")

            episode_avg_reward = episode_reward / (episode_timesteps)
            policy.avg_reward.append(episode_avg_reward)
            policy.save_reward()

            policy.save(f"./models/{file_name}")
            # Reset environment  
            state,reward, done,end_sim = env.reset(replay_buffer,t+1)     
            episode_reward = float(reward)
            episode_timesteps = 0#1
            episode_num += 1            
            
        if end_sim == 1:
            break
        
        # Evaluate episode
        if (t + 1) % eval_freq == 0:
            #evaluations.append(eval_policy(policy))
            evaluations+=1
            policy.save(f"./results/{file_name}_{evaluations}")
            
    # policy.plot_avg_reward()


TCP_conn.close_tcp()
print("connection disconnected!")