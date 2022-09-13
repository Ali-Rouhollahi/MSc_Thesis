clc; 
clear all; 
close all;
% warning off;

%%%%%%%%%%%%%%%%%%%%%Environment Parameters%%%%%%%%%%%%%%%%%%%%
g = 9.81;
grfgrf = 700;

%up_lvl = 0.6;
down_lvl =  -1.2;
warning_lvl = 0.67;

%%%%%%%%%%%%%%%%%%%%%Robot Parameters%%%%%%%%%%%%%%%%%%%%%%%%%%
h_body = -0.63;

B = 2/10; %previous val was 2
K_F = 2*50;%Front
K_B = 2*50;%Back

Q0_Crank_FL = deg2rad(180); 
Q0_Crank_FR = deg2rad(180); 
Q0_Crank_BL = deg2rad(180); 
Q0_Crank_BR = deg2rad(180);

Q0_femur_tibia = deg2rad(-60); %[deg]
Q0_Ankle = deg2rad(-130); %[deg]
K_Ank = 50;
B_Ank = 3; %[N.m/rad/s]

p = 1; % a CPG parameter


Kc = -150;


%%%% Change Mass Center
m_FM = 0;
m_BM = 0;
m_body = 10 - m_FM - m_BM;%kg

m_femur = 1;%kg
m_tibia = 1;%kg
m_gluteal = 0.7;%kg
m_biceps = 0.7;%kg
m_crank = 0.2;%kg
m_leg = m_femur+m_tibia+m_gluteal+m_biceps+m_crank;

m_total = m_body + 4*m_leg;

% sync_actuation = 1*0;
% ground_actuation = 0;

uni_spring_F = 1;
uni_spring_B = 1;
stiffness = 4.0;
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%                       Virtual Ground parameters                         %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Body offset from Ground

hz_0 = -1.2;%[m]
% hz_0_hip = -0.4;

% stiffness of vertical ground interaction
k_gy = (m_leg*1)*g/0.005;             %[N/m]  =(sum of weights)*G/coefficient

% sliding to stiction transition velocity limit
vLimit = 0.01;                  %[m/s]

% max relaxation speed of vertical ground interaction
v_gy_max = 0.035;                %[m/s]

% sliding friction coefficient
mu_slide = 0.8;

% stiffness of horizontal ground stiction
k_gx = (1)*g/0.05;              %[N/m] 0.01

% max relaxation speed of horizontal ground stiction
v_gx_max = 0.03;                %[m/s] 0.03

% stiction to sliding transition coefficient
mu_stick = 0.9;

onoff_friction = 1;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%

%action bounds
% min_actions=[0   ,0   ,0   ,0]; %dq_FL,dq_BR,dq_BL,a
% max_actions=[2*pi,2*pi,2*pi,8]; %dq_FL,dq_BR,dq_BL,a
% min_actions=[5*pi/6 ,5*pi/6 ,-pi/6 ,4]; %dq_FL,qd_BR,dq_BL,a
% max_actions=[7*pi/6 ,7*pi/6 ,pi/6  ,8]; %dq_FL,dq_BR,dq_BL,a
min_actions=[-pi ,-pi ,-pi ,3]; %dq_FL,qd_BR,dq_BL,a
max_actions=[pi  ,pi  ,pi  ,8]; %dq_FL,dq_BR,dq_BL,a
% min_actions=[pi/2   , pi/2   ,-pi/2 ,4]; %dq_FL,qd_BR,dq_BL,a
% max_actions=[3*pi/2 , 3*pi/2 ,pi/2  ,10]; %dq_FL,dq_BR,dq_BL,a

% state_data = csvread('States_MAIN.csv');
% max_states = max(state_data);
% min_states = min(state_data);
max_states = [deg2rad(130),deg2rad(130),deg2rad(130),deg2rad(130),0,0];
min_states = [deg2rad(10),deg2rad(10),deg2rad(10),deg2rad(10),0,0];


RunTime = 15;
%sim('single_leg_one_actuator',RunTime);
