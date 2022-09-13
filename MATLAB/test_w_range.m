Parameters
load('test.mat');

RunTime
a = length(W_all)
i = 1;
% w = 5.6 ;
% q_FL = pi;
% q_BR = 0;
% q_BL = pi;

b = RunTime/a;
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
set_param(file_name,'SimulationCommand','start','SimulationCommand','pause');

set_param(strcat(file_name,'/CPG/a'),'Gain',num2str(W_all(i)));
set_param(strcat(file_name,'/CPG/dphi_FL'),'Gain',num2str(q_FL_all(i)));
set_param(strcat(file_name,'/CPG/dphi_BR'),'Gain',num2str(q_BR_all(i)));
set_param(strcat(file_name,'/CPG/dphi_BL'),'Gain',num2str(q_BL_all(i)));

set_param(file_name, 'SimulationCommand','step');

u1 = stance.data(end,:);
while u1 == 0
    set_param(file_name, 'SimulationCommand','step');
    u1 = stance.data(end,:);
end
disp('touched ground')


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
    time = get_param(file_name,'SimulationTime');
    if time > b
        i = i+1
        b = b + RunTime/a;
        set_param(strcat(file_name,'/CPG/a'),'Gain',num2str(W_all(i)));
        set_param(strcat(file_name,'/CPG/dphi_FL'),'Gain',num2str(q_FL_all(i)));
        set_param(strcat(file_name,'/CPG/dphi_BR'),'Gain',num2str(q_BR_all(i)));
        set_param(strcat(file_name,'/CPG/dphi_BL'),'Gain',num2str(q_BL_all(i)));
    end    
    
    sys_state = get_param(file_name,'SimulationStatus');
end