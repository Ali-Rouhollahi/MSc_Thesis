function Plots(addr,feature)

t_mat = load(strcat(addr,'times.mat'));
[run_num,~]=size(t_mat.t_all);

data_mat = {};
for i=1:run_num
    data_mat = [data_mat;load(strcat(addr,t_mat.t_all{i}))];
end
%%

files = dir(strcat(addr,'*.txt')) ; 
N = length(files) ;
reward_all = cell(N,1);
reward_all_part1 = cell(N,1);
reward_all_part3 = cell(N,1);
size_arr = zeros(N,1);
for i = 1:N
    fileID = fopen(strcat(addr,files(i).name),'r');
    A = fscanf(fileID,['%s'],[1,Inf]);
    i1 = strfind(A,'[');
    i2 = strfind(A,']');
    reward = A(i1+1:i2-1);
    reward = textscan(reward,'%f,');
    reward_all{i} = reward{1};
    reward_all_part1{i} = data_mat{i}.part1_avg;
    reward_all_part3{i} = data_mat{i}.part3_avg;
    fclose(fileID);
    [size_arr(i,1),~] = size(reward_all{i});
end
reward_avg = zeros(N,max(size_arr));
reward_avg_part1 = zeros(N,max(size_arr));
reward_avg_part3 = zeros(N,max(size_arr));
for i = 1:N
    reward_avg(i,1:numel(reward_all{i})) = reward_all{i};
    reward_avg_part1(i,1:numel(reward_all_part1{i})) = reward_all_part1{i};
    reward_avg_part3(i,1:numel(reward_all_part3{i})) = reward_all_part3{i};
end

temp_arr = zeros(1,max(size_arr));
shade_max = temp_arr;
shade_min = temp_arr;
for j = 1:max(size_arr)
    temp_arr(1,j) = mean(nonzeros(reward_avg(:,j)));
    shade_max(1,j) = max(nonzeros(reward_avg(:,j)));
    shade_min(1,j) = min(nonzeros(reward_avg(:,j)));
end
% figure('visible','off');
figure;
fill([1:max(size_arr) fliplr(1:max(size_arr))], [shade_max fliplr(shade_min)], [.9 .9 .9], 'linestyle', 'none')
hold on
plot(1:max(size_arr),temp_arr,'b','LineWidth',1.5)
hold on;
plot(max(size_arr)-4:max(size_arr),ones(1,5)*mean(temp_arr(end-4:end)))
hold on;
text(max(size_arr)-4,mean(temp_arr(end-4:end)),num2str(mean(temp_arr(end-4:end))))
xlabel('Episode')
ylabel('Reward')
ylim([-100 150]);
title(strcat('Rewards over training ',feature));
saveas(gcf,strcat(addr,'Rewards',feature,'.png'))

% temp_arr = zeros(1,max(size_arr));
% shade_max = temp_arr;
% shade_min = temp_arr;
% for j = 1:max(size_arr)
%     temp_arr(1,j) = mean(nonzeros(reward_avg_part1(:,j)));
%     shade_max(1,j) = max(nonzeros(reward_avg_part1(:,j)));
%     shade_min(1,j) = min(nonzeros(reward_avg_part1(:,j)));
% end
% figure('visible','off');
% fill([1:max(size_arr) fliplr(1:max(size_arr))], [shade_max fliplr(shade_min)], [.9 .9 .9], 'linestyle', 'none')
% hold on
% plot(1:max(size_arr),temp_arr,'b','LineWidth',1.5)
% xlabel('Episode')
% ylabel('Reward')
% ylim([-100 150]);
% title(strcat('Rewards(part1) over training ',feature));
% saveas(gcf,strcat(addr,'Rewards(part1)',feature,'.png'))

% temp_arr = zeros(1,max(size_arr));
% shade_max = temp_arr;
% shade_min = temp_arr;
% for j = 1:max(size_arr)
%     temp_arr(1,j) = mean(nonzeros(reward_avg_part3(:,j)));
%     shade_max(1,j) = max(nonzeros(reward_avg_part3(:,j)));
%     shade_min(1,j) = min(nonzeros(reward_avg_part3(:,j)));
% end
% figure('visible','off');
% fill([1:max(size_arr) fliplr(1:max(size_arr))], [shade_max fliplr(shade_min)], [.9 .9 .9], 'linestyle', 'none')
% hold on
% plot(1:max(size_arr),temp_arr,'b','LineWidth',1.5)
% xlabel('Episode')
% ylabel('Reward')
% ylim([-100 150]);
% title(strcat('Rewards(part3) over training ',feature));
% saveas(gcf,strcat(addr,'Rewards(part3)',feature,'.png'))



%%

q_FL = 0;
q_BR = 0;
q_BL = 0;
w = 0;
Vx = 0;
COT = 0;
Stride_len = 0;
Energy = 0;
Tilt_Angle = 0;

for i=1:run_num
    q_FL = data_mat{i}.all_data_rcv(:,1) + q_FL;
    q_BR = data_mat{i}.all_data_rcv(:,2) + q_BR;
    q_BL = data_mat{i}.all_data_rcv(:,3) + q_BL;
    w = data_mat{i}.all_data_rcv(:,4) + w;
    Vx = data_mat{i}.all_data_send(:,5) + Vx;
    COT = data_mat{i}.all_data_send(:,10)./data_mat{i}.all_data_send(:,12) + COT;
    Stride_len = data_mat{i}.all_data_send(:,12) + Stride_len;
    Energy = data_mat{i}.all_data_send(:,10) + Energy;
    Tilt_Angle = data_mat{i}.all_data_send(:,8) + Tilt_Angle;
end
q_FL = q_FL/run_num;
q_BR = q_BR/run_num;
q_BL = q_BL/run_num;
Vx = Vx/run_num;
w = w/run_num;
COT = COT/run_num;
Stride_len = Stride_len/run_num;
Energy = Energy/run_num;
Tilt_Angle = Tilt_Angle/run_num;

figure('visible','off');
[dim ,~] = size(q_FL);
plot(1:dim,q_FL);
hold on;
plot(dim-10:dim,ones(1,11)*mean(q_FL(end-10:end)))
text(dim-7,mean(q_FL(end-10:end)),num2str(mean(q_FL(end-10:end))))
title(strcat('\Delta\phi_{FL} over training trials ',feature));
xlabel('trials')
ylabel('\Delta\phi_{FL} [rad]')
ylim([2.2 3.8]);
saveas(gcf,strcat(addr,'FL',feature,'.png'))

figure('visible','off');
plot(1:dim,q_BR);
hold on;
plot(dim-10:dim,ones(1,11)*mean(q_BR(end-10:end)))
text(dim-7,mean(q_BR(end-10:end)),num2str(mean(q_BR(end-10:end))))
title(strcat('\Delta\phi_{BR} over training trials ',feature));
xlabel('trials');
ylabel('\Delta\phi_{BR} [rad]')
ylim([-1 1]);
saveas(gcf,strcat(addr,'BR',feature,'.png'))

figure('visible','off');
plot(1:dim,q_BL);
hold on;
plot(dim-10:dim,ones(1,11)*mean(q_BL(end-10:end)))
text(dim-7,mean(q_BL(end-10:end)),num2str(mean(q_BL(end-10:end))))
title(strcat('\Delta\phi_{BL} over training trials ',feature));
xlabel('trials');
ylabel('\Delta\phi_{BL} [rad]')
ylim([2.2 4.5]);
saveas(gcf,strcat(addr,'BL',feature,'.png'))

figure('visible','off');
plot(1:dim,w);
hold on;
plot(dim-10:dim,ones(1,11)*mean(w(end-10:end)))
text(dim-7,mean(w(end-10:end)),num2str(mean(w(end-10:end))))
title(strcat('\omega over training trials ',feature));
xlabel('trials');
ylabel('\omega [rad/s]');
ylim([4.5 8]);
saveas(gcf,strcat(addr,'w',feature,'.png'))

figure('visible','off');
plot(1:dim,Vx);
hold on;
plot(dim-10:dim,ones(1,11)*mean(Vx(end-10:end)))
text(dim-7,mean(Vx(end-10:end)),num2str(mean(Vx(end-10:end))))
title(strcat('Forward Velocity over training trials ',feature));
xlabel('trials');
ylabel('V_{x} [m/s]');
ylim([0.8 1.5]);
saveas(gcf,strcat(addr,'Forward Velocity',feature,'.png'))

figure('visible','off');
plot(4:dim,COT(4:dim));
hold on;
plot(dim-10:dim,ones(1,11)*mean(COT(end-10:end)))
text(dim-7,mean(COT(end-10:end)),num2str(mean(COT(end-10:end))))
title(strcat('COT over training trials ',feature));
xlabel('trials');
ylabel('COT [J/m]');
xlim([0 inf])
ylim([0 2.5])
saveas(gcf,strcat(addr,'COT',feature,'.png'))

figure('visible','off');
plot(4:dim,Stride_len(4:dim));
hold on;
plot(dim-10:dim,ones(1,11)*mean(Stride_len(end-10:end)))
text(dim-7,mean(Stride_len(end-10:end)),num2str(mean(Stride_len(end-10:end))))
title(strcat('Stride Length over training trials ',feature));
xlabel('trials');
ylabel('Stride Length [m]');
xlim([0 inf])
saveas(gcf,strcat(addr,'Stride Length',feature,'.png'))

figure('visible','off');
plot(4:dim,Energy(4:dim));
hold on;
plot(dim-10:dim,ones(1,11)*mean(Energy(end-10:end)))
text(dim-7,mean(Energy(end-10:end)),num2str(mean(Energy(end-10:end))))
title(strcat('Energy over training trials ',feature));
xlabel('trials');
ylabel('Energy [J]');
xlim([0 inf])
ylim([0 0.7])
saveas(gcf,strcat(addr,'Energy',feature,'.png'))

figure('visible','off');
plot(2:dim,Tilt_Angle(2:dim));
hold on;
plot(dim-10:dim,ones(1,11)*mean(Tilt_Angle(end-10:end)))
text(dim-7,mean(Tilt_Angle(end-10:end)),num2str(mean(Tilt_Angle(end-10:end))))
title(strcat('Tilt Angle over training trials ',feature));
xlabel('trials');
ylabel('Tilt Angle [deg]');
xlim([0 inf])
saveas(gcf,strcat(addr,'Tilt Angle',feature,'.png'))


disp(['-----',feature,'------'])
disp(['q_FL : ',num2str(mean(q_FL(end-10:end))),' [rad]'])
disp(['q_BR : ',num2str(mean(q_BR(end-10:end))),' [rad]'])
disp(['q_BL : ',num2str(mean(q_BL(end-10:end))),' [rad]'])
disp(['w : ',num2str(mean(w(end-10:end))),' [rad/s]'])
disp(['Vx : ',num2str(mean(Vx(end-10:end))),' [m/s]'])
disp(['COT : ',num2str(mean(COT(end-10:end))),' [J/m]'])
disp(['Stride Length : ',num2str(mean(Stride_len(end-10:end))),' [m]'])
disp(['Energy : ',num2str(mean(Energy(end-10:end))),' [J]'])
disp(['Tilt Angle : ',num2str(mean(Tilt_Angle(end-10:end))),' [deg]'])


end
