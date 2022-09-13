%% Load Structural parameters
Parameters

%% Setup TCP
% open a client
tcp_clnt = tcpclient('127.0.0.1',9999);
timerVal = tic;
%% Initial Conditions for starting episode
max_run_num = 4;
tcp_tx_data = [max_run_num,0,0,0,0,0,0,0,0,0,0,0,0];
write(tcp_clnt,tcp_tx_data);

if isfile('times.mat')
     % File exists.
     mat_temp = load('times.mat');
     t_all = mat_temp.t_all;
     clear mat_temp
else
     t_all = {};
end
run_num = 0;
while(run_num ~= max_run_num) 
    
    initial_state = min_states + (max_states - min_states).*rand(1,6);
    Q0_Crank_FL=initial_state(1); Q0_Crank_FR=initial_state(2); Q0_Crank_BL=initial_state(3); Q0_Crank_BR = initial_state(4);
    tcp_tx_data = [initial_state,0,0,0,0,0,0,0];
    write(tcp_clnt,tcp_tx_data);
%%% Load Simulink and Initialize some params
    version = num2str(0);
    disp(['version is:',version]);
    file_name = 'Four_leg_Cheetah_ver';
    file_name = strcat(file_name,version);
    open_system(file_name);
    sys_state = get_param(file_name,'SimulationStatus');
    if strcmp(sys_state,'stopped') == 0
        set_param(file_name, 'SimulationCommand', 'stop')    
    end
    % start simulation and pause simulation, waiting for signal from python
    set_param(file_name,'SimulationCommand','start','SimulationCommand','pause');
    %%%
    set_param(strcat(file_name,'/CPG/a'),'Gain',num2str(4));
    set_param(strcat(file_name,'/CPG/dphi_FL'),'Gain',num2str(pi));
    set_param(strcat(file_name,'/CPG/dphi_BR'),'Gain',num2str(pi));
    set_param(strcat(file_name,'/CPG/dphi_BL'),'Gain',num2str(0));
    %%%
    set_param(file_name, 'SimulationCommand','step');


    all_data_rcv = [];
    all_data_send = [];
    all_reward = [];
    all_reward_avg = [];
    part1 = [];
    part1_avg = [];
    part3 = [];
    part3_avg = [];
    % instable = [];
    done = [];
    end_sim = 0;
    
    %%%%
    episode = 0;
    %%%%
    stiffness = 4.0;
    while(end_sim == 0)
        %%% waite until touch with ground
        u1 = stance.data(end,:);
        while u1 == 0
            set_param(file_name, 'SimulationCommand','step');
            u1 = stance.data(end,:);
        end
        disp('touched ground')
        %%%
        terminated = 0;
        prev_data = [0,0,0,0,0,0,0,0,0,0];
        initial_action = (max_actions - min_actions).*rand(1,4) + min_actions;
        set_param(strcat(file_name,'/CPG/dphi_FL'),'Gain',num2str(initial_action(1)));
        set_param(strcat(file_name,'/CPG/dphi_BR'),'Gain',num2str(initial_action(2)));
        set_param(strcat(file_name,'/CPG/dphi_BL'),'Gain',num2str(initial_action(3)));
        set_param(strcat(file_name,'/CPG/a')      ,'Gain',num2str(initial_action(4)));
        episode = episode + 1;
        if episode>= 5
           stiffness = 1.0; 
        end
        index = 0;
        index_old = 1;
        while(terminated == 0)
            % TCP receiving
            while(1) % loop, until getting some data
                nBytes = get(tcp_clnt,'BytesAvailable');
                if nBytes > 0
                    b = nBytes
                    break;
                end
            end

            command_rev = read(tcp_clnt,nBytes); % read() will read binary as str
            rcv_data = str2num(char(command_rev)); % transform str into numerical matrix

            terminated = rcv_data(end-1); % separate each data in the matrix
            end_sim = rcv_data(end);


            if(terminated)
                continue;
            end
            if end_sim == 1
                 break;
            end

            all_data_rcv = [all_data_rcv;rcv_data]; % store history data

            if isempty(rcv_data)
                n = rcv_data;
                rcv_data = [0,0,0,0,0,0,0];%control params + termination
            end

            %set parameter in the simulink model using the data from python
            set_param(strcat(file_name,'/CPG/dphi_FL'),'Gain',num2str(rcv_data(1)));
            set_param(strcat(file_name,'/CPG/dphi_BR'),'Gain',num2str(rcv_data(2)));
            set_param(strcat(file_name,'/CPG/dphi_BL'),'Gain',num2str(rcv_data(3)));
            set_param(strcat(file_name,'/CPG/a')      ,'Gain',num2str(rcv_data(4)));

            %run the simulink model till a change leg
            u_old = stance.data(end,:);
            k = 0;
            while (u1 == u_old) || (u1 == 0)|| (u1 == 3)
                set_param(file_name, 'SimulationCommand','step');
                u1 = stance.data(end,:);
                k = k+2;
                if Data.data(end,9) > 0
                    disp('unstable');
                    break;
                end
            end

            % TCP sending
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
            w = [v,stride_length,tfs];%12,13
            write(tcp_clnt, w);
            all_data_send = [all_data_send; w]; % store history data
            instability = sim_data(9);
            cot = w(10)/w(12);
            Rf = exp(4*(sim_data(5) - 0.6));
            r = 50/(abs(cot) + 1)  + instability*(-100) + Rf + 1200/exp(abs(sim_data(8)));
            all_reward = [all_reward ; r];
            part1 = [part1;50.0/(abs(cot) + 1)];
            part3 = [part3;Rf];        
            index_old = index ;
        end
        if end_sim == 1
            set_param(file_name, 'SimulationCommand', 'stop')
            break;
        end
        all_reward_avg = [all_reward_avg ; mean(all_reward)];
        part1_avg = [part1_avg; mean(part1)];
        part3_avg = [part3_avg; mean(part3)];
        all_reward = [];
        part1 = [];
        part3 = [];

        set_param(file_name, 'SimulationCommand', 'stop')
        initial_state = min_states + (max_states - min_states).*rand(1,6);
        Q0_Crank_FL=initial_state(1); Q0_Crank_FR=initial_state(2); Q0_Crank_BL=initial_state(3); Q0_Crank_BR=initial_state(4);
        tcp_tx_data = [initial_state,0,0,0,0,0,0,0];
        write(tcp_clnt,tcp_tx_data);
        set_param(file_name,'SimulationCommand','start','SimulationCommand','pause');
    end


    time_t = datestr(datetime,'yyyy-mm-dd-HH-MM');
    disp(['finished:',num2str(run_num+1)])
    elapsedTime = toc(timerVal)
    t_all = [t_all ;time_t];
    save(time_t)
    save('times.mat','t_all')
    run_num = run_num + 1;
    
end
