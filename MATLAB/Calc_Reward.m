%% Load Structural parameters
Parameters

w = 5.6 ;
q_FL = pi;
q_BR = pi;
q_BL = 0;
% w = 5.8006;
% q_FL = 2.8177;
% q_BR = -0.48683;
% q_BL = 2.6433;
%% Initial Conditions for starting episode
%%% Load Simulink and Initialize some params
version = num2str(0);
disp(['version is:',version]);
file_name = 'Four_leg_Cheetah_ver';
file_name = strcat(file_name,version);
% open_system(file_name);
load_system(file_name);
sys_state = get_param(file_name,'SimulationStatus');
if strcmp(sys_state,'stopped') == 0
    set_param(file_name, 'SimulationCommand', 'stop')    
end
% start simulation and pause simulation, waiting for signal from python
set_param(file_name,'SimulationCommand','start','SimulationCommand','pause');
%%%
set_param(strcat(file_name,'/CPG/a'),'Gain',num2str(w));
set_param(strcat(file_name,'/CPG/dphi_FL'),'Gain',num2str(q_FL));
set_param(strcat(file_name,'/CPG/dphi_BR'),'Gain',num2str(q_BR));
set_param(strcat(file_name,'/CPG/dphi_BL'),'Gain',num2str(q_BL));

set_param(file_name, 'SimulationCommand','step');

all_data_send = [];
all_reward = [];
part1 = [];
part3 = [];

%%% waite until touch with ground
u1 = stance.data(end,:);
while u1 == 0
    set_param(file_name, 'SimulationCommand','step');
    u1 = stance.data(end,:);
end
disp('touched ground')

prev_data = [0,0,0,0,0,0,0,0,0,0];
index = 0;
index_old = 1;
sys_state = get_param(file_name,'SimulationStatus');
while(~strcmp(sys_state,'stopped'))
    %run the simulink model till a change leg
    u_old = stance.data(end,:);
    while (u1 == u_old) || (u1 == 0) || (u1 == 3) 
        set_param(file_name, 'SimulationCommand','step');
        u1 = stance.data(end,:);
        sys_state = get_param(file_name,'SimulationStatus');
        if strcmp(sys_state,'stopped') == 1
            break;
        end
    end

    sim_data = Data.data(end,:);
    [index ,~] = size(Data.data(:,1));
    sim_data(8) = max(abs(Data.data(index_old:index,8)));%tilt
    sim_data(5)  = max(abs(Data.data(index_old:index,5)));%Vx
    sim_data(6)  = max(abs(Data.data(index_old:index,6)));%Vy    
    X = sim_data(7);%x_body 
    time = get_param(file_name,'SimulationTime');
    v = [sim_data,time];%11
    stride_length = X - prev_data(end);
    tfs = v(end)- prev_data(end-1);
    vx = stride_length/tfs;
    prev_data = [v,X];
    W = [v,stride_length,tfs];%12,13
    all_data_send = [all_data_send; W]; % store history data
    instability = sim_data(9);
    cot = W(10)/W(12);
    Rf = exp(4*(sim_data(5) - 0.6));
    r = 50/(abs(cot) + 1)  + instability *(-100) + Rf + 1200/exp(abs(sim_data(8)));
    all_reward = [all_reward ; r];
    part1 = [part1;50/(abs(cot) + 1)];
    part3 = [part3;Rf];        
    index_old = index ;
    sys_state = get_param(file_name,'SimulationStatus');
end

%%
close all
figure;
[dim ,~] = size(all_reward);
plot(1:dim,all_reward);
hold on;
plot(dim-10:dim,ones(1,11)*mean(all_reward(end-10:end-3)))
text(dim-7,mean(all_reward(end-10:end-3)),num2str(mean(all_reward(end-10:end-3))))
title('Reward over Evaluating');
xlabel('Step');
ylabel('Reward');
ylim([0 inf])
text(2,10,['\omega = ',num2str(w),', \Delta\phi_{FL} = ',num2str(q_FL),', \Delta\phi_{BR} = ',num2str(q_BR),', \Delta\phi_{BL} = ',num2str(q_BL)])
















