%% Load Structural parameters
Parameters

%% Setup TCP
% open a client
tcp_clnt = tcpclient('127.0.0.1',9999);
timerVal = tic;
%% Initial Conditions for starting episode
% w_rng = (2.5:0.5:11);
w_rng = (5.0:0.5:5.0);
[w_sz,~] = size(w_rng');
max_run_num = 5;
tcp_tx_data = [max_run_num ,w_sz,0,0,0,0,0,0,0,0,0,0,0];
write(tcp_clnt,tcp_tx_data);

if isfile('times.mat')
     % File exists.
     mat_temp = load('times.mat');
     t_all = mat_temp.t_all;
     clear mat_temp
else
     t_all = {};
end

for w = w_rng
    run_num = 0;
    while(run_num ~= max_run_num)

%         initial_state = min_states + (max_states - min_states).*rand(1,6);
%         Q0_Crank_FL=initial_state(1); Q0_Crank_FR=initial_state(2); Q0_Crank_BL=initial_state(3); Q0_Crank_BR = initial_state(4);
%         tcp_tx_data = [initial_state,0,0,0,0,0,0,0];
        tcp_tx_data = [pi,pi,pi,pi,0,0,0,0,0,0,0,0,0];
        write(tcp_clnt,tcp_tx_data);
        %%% Load Simulink and Initialize some params
        version = num2str(1);
        disp(['version is:',version]);
        file_name = 'Four_leg_Cheetah_ver';
        file_name = strcat(file_name,version);
        open_system(file_name);
        sys_state = get_param(file_name,'SimulationStatus');
        if strcmp(sys_state,'stopped') == 0
            set_param(gcs, 'SimulationCommand', 'stop')    
        end
        % start simulation and pause simulation, waiting for signal from python
        set_param(gcs,'SimulationCommand','start','SimulationCommand','pause');
        %%%
        set_param(strcat(file_name,'/CPG/a'),'Gain',num2str(4));
        set_param(strcat(file_name,'/CPG/dphi_FL'),'Gain',num2str(pi));
        set_param(strcat(file_name,'/CPG/dphi_BR'),'Gain',num2str(pi));
        set_param(strcat(file_name,'/CPG/dphi_BL'),'Gain',num2str(0));
        %%%
%         set_param(gcs, 'SimulationCommand','step');
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
        end_sim = 0;

        while(end_sim == 0)
            %%% waite until touch with ground
            u1 = stance.data(end,:);
            while u1 == 0
                set_param(gcs, 'SimulationCommand','step');
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
                rcv_data = str2num(char(command_rev)) % transform str into numerical matrix

                terminated = rcv_data(end-1); % separate each data in the matrix
                end_sim = rcv_data(end);


                if(terminated)
                    continue;
                end
                if end_sim == 1
                     break;
                end
                rcv_data(4) = w;
                all_data_rcv = [all_data_rcv;rcv_data]; % store history data

                if isempty(rcv_data)
                    n = rcv_data;
                    rcv_data = [0,0,0,0,0,0,0];%control params + termination
                end

                %set parameter in the simulink model using the data from python
                set_param(strcat(file_name,'/CPG/dphi_FL'),'Gain',num2str(rcv_data(1)));
                set_param(strcat(file_name,'/CPG/dphi_BR'),'Gain',num2str(rcv_data(2)));
                set_param(strcat(file_name,'/CPG/dphi_BL'),'Gain',num2str(rcv_data(3)));
%                 set_param(strcat(file_name,'/CPG/a')      ,'Gain',num2str(rcv_data(4)));
                set_param(strcat(file_name,'/CPG/a')      ,'Gain',num2str(w));

                %run the simulink model till a change leg
                u_old = stance.data(end,:);
                k = 0;
                while (u1 == u_old) || (u1 == 0)|| (u1 == 3)
                    set_param(gcs, 'SimulationCommand','step');
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
                time = get_param(gcs,'SimulationTime');
                v = [sim_data,time];%11
                stride_length = X - prev_data(end);
                tfs = v(end)- prev_data(end-1);
                vx = stride_length/tfs;
                prev_data = [v,X];
                W = [v,stride_length,tfs];%12,13
                write(tcp_clnt, W);
                all_data_send = [all_data_send; W]; % store history data
                instability = sim_data(9);
                cot = W(10)/W(12);
                Rf = exp(4*(sim_data(5)));
                r = 50/(abs(cot) + 1)  + instability*(-100) + Rf + 1200/exp(abs(sim_data(8)));
                all_reward = [all_reward ; r];
                part1 = [part1;50/(abs(cot) + 1)];
                part3 = [part3;Rf];        
                index_old = index ;
            end
            if end_sim == 1
                set_param(gcs, 'SimulationCommand', 'stop')
                break;
            end
            all_reward_avg = [all_reward_avg ; mean(all_reward)];
            part1_avg = [part1_avg; mean(part1)];
            part3_avg = [part3_avg; mean(part3)];
            all_reward = [];
            part1 = [];
            part3 = [];

            set_param(gcs, 'SimulationCommand', 'stop')
%             initial_state = min_states + (max_states - min_states).*rand(1,6);
%             Q0_Crank_FL=initial_state(1); Q0_Crank_FR=initial_state(2); Q0_Crank_BL=initial_state(3); Q0_Crank_BR=initial_state(4);
%             tcp_tx_data = [initial_state,0,0,0,0,0,0,0];
            tcp_tx_data = [pi,pi,pi,pi,0,0,0,0,0,0,0,0,0];
            write(tcp_clnt,tcp_tx_data);
            set_param(gcs,'SimulationCommand','start','SimulationCommand','pause');
        end

        time_t = datestr(datetime,'yyyy-mm-dd-HH-MM');
        time_t = strcat(time_t,'_w_',num2str(w),'.mat');
        disp(['finished:',num2str(run_num+1)])
        elapsedTime = toc(timerVal)
        t_all = [t_all ;time_t];
        save('times.mat','t_all');
        save(time_t);
        run_num = run_num + 1;    
    end
end
