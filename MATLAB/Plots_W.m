function Plots_W(addr,feature_1)

t_mat = load(strcat(addr,'times.mat'));
[run_num,~]=size(t_mat.t_all);

data_mat = {};
for i=1:run_num
    data_mat = [data_mat;load(strcat(addr,t_mat.t_all{i}))];
end

w_all = [];
for i=1:run_num
    w_all = [w_all;data_mat{i}.w];
end
q_FL_all = [];
q_BR_all = [];
q_BL_all = [];
W_all = [];
Vx_all = [];
COT_all = [];
w_rng = 2.0:0.5:11;
for w = w_rng
    index = find(w == w_all);
    if isempty(index)
        continue;
    end
    feature = strcat('(w=',num2str(w),',',feature_1,')');
    %%%%%%%%%%%%%%%
    figure;
    files = dir(strcat(addr,'*.txt')) ; 
    N = length(files) ;
    reward_all = cell(N,1);
    size_arr = zeros(N,1);
    for i = 1:N
        fileID = fopen(strcat(addr,files(i).name),'r');
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
    saveas(gcf,strcat(addr,'Rewards',feature,'.png'))   
    %%%%%%%%%%%%%%%
    

    q_FL = 0;
    q_BR = 0;
    q_BL = 0;
    W = 0;
    Vx = 0;
    COT = 0;
    for i=1:length(index)
        q_FL = data_mat{index(i)}.all_data_rcv(:,1) + q_FL;
        q_BR = data_mat{index(i)}.all_data_rcv(:,2) + q_BR;
        q_BL = data_mat{index(i)}.all_data_rcv(:,3) + q_BL;
        W = data_mat{index(i)}.all_data_rcv(:,4) + W;
        Vx = data_mat{index(i)}.all_data_send(:,5) + Vx;
        COT = data_mat{index(i)}.all_data_send(:,10)./data_mat{index(i)}.all_data_send(:,12) + COT;
    end
    q_FL = q_FL/length(index);
    q_BR = q_BR/length(index);
    q_BL = q_BL/length(index);
    Vx = Vx/length(index);
    W = W/length(index);
    COT = COT/length(index);

    figure('visible','off');
    [dim ,~] = size(q_FL);
    plot(1:dim,q_FL);
    hold on;
    plot(dim-10:dim,ones(1,11)*mean(q_FL(end-10:end)))
    text(dim-7,mean(q_FL(end-10:end)),num2str(mean(q_FL(end-10:end))))
    title(strcat('\Delta\phi_{FL} over training trials ',feature));
    xlabel('trials')
    ylabel('\Delta\phi_{FL}')
%     ylim([2.2 3.8]);
    saveas(gcf,strcat(addr,'FL',feature,'.png'))

    figure('visible','off');
    plot(1:dim,q_BR);
    hold on;
    plot(dim-10:dim,ones(1,11)*mean(q_BR(end-10:end)))
    text(dim-7,mean(q_BR(end-10:end)),num2str(mean(q_BR(end-10:end))))
    title(strcat('\Delta\phi_{BR} over training trials ',feature));
    xlabel('trials');
    ylabel('\Delta\phi_{BR}')
%     ylim([-1 1]);
    saveas(gcf,strcat(addr,'BR',feature,'.png'))

    figure('visible','off');
    plot(1:dim,q_BL);
    hold on;
    plot(dim-10:dim,ones(1,11)*mean(q_BL(end-10:end)))
    text(dim-7,mean(q_BL(end-10:end)),num2str(mean(q_BL(end-10:end))))
    title(strcat('\Delta\phi_{BL} over training trials ',feature));
    xlabel('trials');
    ylabel('\Delta\phi_{BL}')
%     ylim([2.2 4.5]);
    saveas(gcf,strcat(addr,'BL',feature,'.png'))

%     figure('visible','off');
%     plot(1:dim,W);
%     hold on;
%     plot(dim-10:dim,ones(1,11)*mean(W(end-10:end)))
%     text(dim-7,mean(W(end-10:end)),num2str(mean(W(end-10:end))))
%     title(strcat('w over training trials ',feature));
%     xlabel('trials');
%     ylabel('\omega');
%     ylim([4.5 8]);
%     saveas(gcf,strcat(addr,'w',feature,'.png'))

    figure('visible','off');
    plot(1:dim,Vx);
    hold on;
    plot(dim-10:dim,ones(1,11)*mean(Vx(end-10:end)))
    text(dim-7,mean(Vx(end-10:end)),num2str(mean(Vx(end-10:end))))
    title(strcat('Forward Velocity over training trials ',feature));
    xlabel('trials');
    ylabel('V_{x}');
%     ylim([0.8 1.5]);
    saveas(gcf,strcat(addr,'Forward Velocity',feature,'.png'))


    disp(['q_FL : ',num2str(mean(q_FL(end-10:end))),' [rad]'])
    disp(['q_BR : ',num2str(mean(q_BR(end-10:end))),' [rad]'])
    disp(['q_BL : ',num2str(mean(q_BL(end-10:end))),' [rad]'])
    disp(['w : ',num2str(w),' [rad/s]'])
    disp(['Vx : ',num2str(mean(Vx(end-10:end))),' [m/s]'])
    disp('--------------------');
    q_FL_all = [q_FL_all;mean(q_FL(end-10:end))];
    q_BR_all = [q_BR_all;mean(q_BR(end-10:end))];
    q_BL_all = [q_BL_all;mean(q_BL(end-10:end))];
    W_all = [W_all;w];
    Vx_all = [Vx_all;mean(Vx(end-10:end))];   
    COT_all = [COT_all;mean(COT(end-10:end))];
end

figure('visible','off');
plot(W_all,q_FL_all);
% title(strcat('Velocity Frequency ',feature));
xlabel('\omega [rad/s]');
ylabel('\Delta\phi_{FL} [rad]');
saveas(gcf,strcat(addr,'qFL_Frequency','.png'))

figure('visible','off');
plot(W_all,q_BR_all);
% title(strcat('Velocity Frequency ',feature));
xlabel('\omega [rad/s]');
ylabel('\Delta\phi_{BR} [rad]');
saveas(gcf,strcat(addr,'qBR_Frequency','.png'))

figure('visible','off');
plot(W_all,q_BL_all);
% title(strcat('Velocity Frequency ',feature));
xlabel('\omega [rad/s]');
ylabel('\Delta\phi_{BL} [rad]');
saveas(gcf,strcat(addr,'qBL_Frequency','.png'))

figure('visible','off');
plot(W_all,Vx_all);
% title(strcat('Velocity Frequency ',feature));
xlabel('\omega [rad/s]');
ylabel('V_{x}[m/s]');
saveas(gcf,strcat(addr,'Velocity_Frequency','.png'))

figure('visible','off');
plot(W_all,COT_all);
% title(strcat('Velocity Frequency ',feature));
xlabel('\omega [rad/s]');
ylabel('COT [J/m]');
saveas(gcf,strcat(addr,'COT_Frequency','.png'))
end
