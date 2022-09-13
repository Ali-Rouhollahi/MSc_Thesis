clc; 
clear all; 

feature = '';
t_mat = load('times.mat');
[run_num,~]=size(t_mat.t_all);

data_mat = [];
for i=1:run_num
    data_mat = [data_mat;load(t_mat.t_all(i,:))];
end
%%
figure;
files = dir('*.txt') ; 
N = length(files) ;
reward_all = cell(N,1);
size_arr = zeros(N,1);
for i = 1:N
    fileID = fopen(files(i).name,'r');
    A = fscanf(fileID,['%s'],[1,Inf]);
    i1 = strfind(A,'[');
    i2 = strfind(A,']');
    reward = A(i1+1:i2-1);
    reward = textscan(reward,'%f,');
    reward_all{i} = reward{1};    
    fclose(fileID);
    [size_arr(i,1),~] = size(reward_all{i});
end
reward_avg = zeros(N,max(size_arr));
for i = 1:N
    reward_avg(i,1:numel(reward_all{i})) = reward_all{i};
end
a = zeros(1,max(size_arr));
shade_max = a;
shade_min = a;
for j = 1:max(size_arr)
    a(1,j) = mean(nonzeros(reward_avg(:,j)));
    shade_max(1,j) = max(nonzeros(reward_avg(:,j)));
    shade_min(1,j) = min(nonzeros(reward_avg(:,j)));
end
fill([1:max(size_arr) fliplr(1:max(size_arr))], [shade_max fliplr(shade_min)], [.9 .9 .9], 'linestyle', 'none')
hold on
plot(1:max(size_arr),a,'b','LineWidth',1.5)
xlabel('Episode')
ylabel('Reward')
ylim([-100 150]);
title(strcat('Rewards over training ',feature));
saveas(gcf,strcat('Rewards',feature,'.png'))   

%%

q_FL = 0;
q_BR = 0;
q_BL = 0;
w = 0;
Vx = 0;
for i=1:run_num
    q_FL = data_mat(i).all_data_rcv(:,1) + q_FL;
    q_BR = data_mat(i).all_data_rcv(:,2) + q_BR;
    q_BL = data_mat(i).all_data_rcv(:,3) + q_BL;
    w = data_mat(i).all_data_rcv(:,4) + w;
    Vx = data_mat(i).all_data_send(:,5) + Vx;
end
q_FL = q_FL/run_num;
q_BR = q_BR/run_num;
q_BL = q_BL/run_num;
Vx = Vx/run_num;
w = w/run_num;

figure;
[dim ,~] = size(q_FL);
plot(1:dim,q_FL);
hold on;
plot(dim-10:dim,ones(1,11)*mean(q_FL(end-10:end)))
text(dim-7,mean(q_FL(end-10:end)),num2str(mean(q_FL(end-10:end))))
title(strcat('\Delta\phi_{FL} over training trials ',feature));
xlabel('trials')
ylabel('\Delta\phi_{FL}')
ylim([2.2 3.8]);
saveas(gcf,strcat('FL',feature,'.png'))

figure;
plot(1:dim,q_BR);
hold on;
plot(dim-10:dim,ones(1,11)*mean(q_BR(end-10:end)))
text(dim-7,mean(q_BR(end-10:end)),num2str(mean(q_BR(end-10:end))))
title(strcat('\Delta\phi_{BR} over training trials ',feature));
xlabel('trials');
ylabel('\Delta\phi_{BR}')
ylim([-1 1]);
saveas(gcf,strcat('BR',feature,'.png'))

figure;
plot(1:dim,q_BL);
hold on;
plot(dim-10:dim,ones(1,11)*mean(q_BL(end-10:end)))
text(dim-7,mean(q_BL(end-10:end)),num2str(mean(q_BL(end-10:end))))
title(strcat('\Delta\phi_{BL} over training trials ',feature));
xlabel('trials');
ylabel('\Delta\phi_{BL}')
ylim([2.2 4.5]);
saveas(gcf,strcat('BL',feature,'.png'))

figure; 
plot(1:dim,w);
hold on;
plot(dim-10:dim,ones(1,11)*mean(w(end-10:end)))
text(dim-7,mean(w(end-10:end)),num2str(mean(w(end-10:end))))
title(strcat('w over training trials ',feature));
xlabel('trials');
ylabel('\omega');
ylim([4.5 8]);
saveas(gcf,strcat('w',feature,'.png'))

figure;
plot(1:dim,Vx);
hold on;
plot(dim-10:dim,ones(1,11)*mean(Vx(end-10:end)))
text(dim-7,mean(Vx(end-10:end)),num2str(mean(Vx(end-10:end))))
title(strcat('Forward Velocity over training trials ',feature));
xlabel('trials');
ylabel('V_{x}');
ylim([0.8 1.5]);
saveas(gcf,strcat('Forward Velocity',feature,'.png'))


disp(['q_FL : ',num2str(mean(q_FL(end-10:end))),' [rad]'])
disp(['q_BR : ',num2str(mean(q_BR(end-10:end))),' [rad]'])
disp(['q_BL : ',num2str(mean(q_BL(end-10:end))),' [rad]'])
disp(['w : ',num2str(mean(w(end-10:end))),' [rad/s]'])
disp(['Vx : ',num2str(mean(Vx(end-10:end))),' [m/s]'])
