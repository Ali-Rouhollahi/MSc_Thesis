import numpy as np

class Reward():
    def __init__(self):

        self.COT = 0
        self.unstability = 0
        self.vx = 0
        self.stride_length = 0
        self.x_toe = 0
        self.tfs = 0
        self.tilt = 0

        self.v_ref = 0.6#4
        
        self.reward_storage = []

    def calculate_reward(self):

        Rf = np.exp(4*(self.vx))

        # r = 50/(self.COT + 1) + 10/(self.unstability + 1) + 0*Rf + 1200/np.exp(np.abs(self.tilt))
        r = 50 / (np.abs(self.COT) + 1) + self.unstability*(-100) + Rf + 1200 / np.exp(np.abs(self.tilt))
        
        self.reward_storage.append(r)
        return r

    def Set_reward_components(self,data):
        self.unstability = data[0]
        self.COT = data[1]
        self.stride_length = data[2]
        self.vx = data[3]
        self.x_toe = data[4]
        self.tfs = data[5]
        self.tilt = data[6]

    