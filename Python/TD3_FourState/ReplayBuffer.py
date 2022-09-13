import numpy as np
import torch


class ReplayBuffer(object):
    def __init__(self, state_dim, action_dim, max_size=int(1e6)):
        self.max_size=max_size
        self.ptr=0
        self.size=0

        self.state=np.zeros((max_size,state_dim))
        self.action=np.zeros((max_size,action_dim))
        self.next_state=np.zeros((max_size,state_dim))
        self.reward=np.zeros((max_size,1))
        self.not_done=np.zeros((max_size,1))


    def add(self,state,action,next_state,reward,done):
        self.state[self.ptr]=state
        self.action[self.ptr]=action
        self.next_state[self.ptr]=next_state
        self.reward[self.ptr]=reward
        self.not_done[self.ptr]=1.-done

        self.ptr=(self.ptr +1) % self.max_size
        self.size=min(self.size+1,self.max_size)

    def sample(self, batch_size):
        ind=np.random.randint(0,self.size,size=batch_size)
        
        return ( 
            torch.FloatTensor(self.state[ind]),
            torch.FloatTensor(self.action[ind]),
            torch.FloatTensor(self.next_state[ind]),
            torch.FloatTensor(self.reward[ind]),
            torch.FloatTensor(self.not_done[ind])
        )
    def reset_sample(self, batch_size):
        ind = self.max_size - 1
        while(self.not_done[ind]==0):
            ind=np.random.randint(0,self.size,size=batch_size)
        
        return ( 
            torch.FloatTensor(self.state[ind]),
            torch.FloatTensor(self.action[ind]),
            torch.FloatTensor(self.next_state[ind]),
            torch.FloatTensor(self.reward[ind]),
            torch.FloatTensor(self.not_done[ind])
        )

    def tofile(self):
        filename='./replay_buf/'
        np.savetxt(filename+'state.txt',self.state)
        np.savetxt(filename+'action.txt',self.action)
        np.savetxt(filename+'next_state.txt',self.next_state)
        np.savetxt(filename+'reward.txt',self.reward)
        np.savetxt(filename+'done.txt',self.not_done)
        size=[self.size]
        np.savetxt(filename+'size.txt',size)

    def fromfile(self):
        filename='./replay_buf/'
        self.state = np.loadtxt(filename+'state.txt')
        self.action = np.loadtxt(filename+'action.txt')
        self.next_state = np.loadtxt(filename+'next_state.txt')
        self.reward = np.loadtxt(filename+'reward.txt')
        self.not_done = np.loadtxt(filename+'done.txt')
        self.size = np.loadtxt(filename+'size.txt')
        #self.size=len(self.state)