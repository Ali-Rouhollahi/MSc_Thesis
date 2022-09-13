clc; 
clear all; 
close all;
warning off;


% time_t = datestr(datetime,'yyyy-mm-dd-HH-MM')
% time_t = strcat(time_t,'_w_',num2str(1))
% rng = (2:0.5:11)';
% [a,~] = size(rng)
% for w = rng
%    disp(w)
% end
% disp(datetime)

% if isfile('times.mat')
%      % File exists.
%      mat = load('times.mat');
%      t_all = mat.t_all
% else
%      t_all = [];
% end

% version = num2str(0);
% a = 'A'
% file_name = strcat('Four_leg_Cheetah_ver (',a,')')

% b = load('2022-08-04-16-46_w_2.mat');


% a = load('times.mat');
% a.t_all{1} = strcat(a.t_all{1},'.mat');
% a.t_all{2} = strcat(a.t_all{2},'.mat');
% a.t_all{3} = strcat(a.t_all{3},'.mat');
% a.t_all{4} = strcat(a.t_all{4},'.mat');
% a.t_all{5} = strcat(a.t_all{5},'.mat');
% a.t_all{6} = strcat(a.t_all{6},'.mat');
% a.t_all{7} = strcat(a.t_all{7},'.mat');
% a.t_all{8} = strcat(a.t_all{8},'.mat');
% t_all = a.t_all;
% clear a


% figure('visible','off');



%%

% Plots('../Data/six_state_nospring/','(6 State)')
% Plots('../Data/six_state_spring/','(6 State with Spring)')
% Plots('../Data/four_state_nospring/','(4 State)')
% Plots('../Data/four_state_spring/','(4 State with Spring)')

% Plots_W('../Data/w_range/','')

% Plots_W('../Data/six_state_nospring/','')
% Plots_W('../Data/six_state_spring/',' with Spring')
% Plots('../Data/six_state_nospring/','')
% Plots('../Data/six_state_spring/','(with Spring)')
% Plots('../Data/six_state_spring/stability/','(Opt Comp)')
% Plots('../Data/six_state_spring/soft_stablility/','(Soft Comp)')
% Plots('../Data/six_state_spring/stiff_stability/','(Stiff Comp)')
% Plots('../Data/six_state_nospring/stability/','(No Comp)')
Plots('../Data/six_state_spring/COT_Vx/','(Opt Comp)')
Plots('../Data/six_state_nospring/COT_Vx/','(No Comp)')
Plots('../Data/six_state_nospring/COT/','(No Comp(COT))')
Plots('../Data/six_state_spring/COT/','(Opt Comp(COT))')
Plots('../Data/six_state_spring/COT_Nonlinear/','(Non-Uniform Comp(COT))')
% Plots('../Data/six_state_nospring/Vx_NoSpring/','(No Comp)'); 
% Plots('../Data/six_state_spring/Vx_Spring/','(Opt Comp)');
Plots('../Data/six_state_nospring/Vx_Vref_NoSpring/','(No Comp(vref))'); 
Plots('../Data/six_state_spring/Vx_Vref_Spring/','(Opt Comp(vref))');
Plots('../Data/six_state_spring/Vx_Vref_NonlinearSpring/','(Nonlinear Comp(vref))')
Plots('../Data/six_state_spring/grad_rew_spring/','(Nonlinear Comp(grad rew))'); 
Plots('../Data/six_state_nospring/grad_rew_nospring/','(No Comp(grad rew))');
;










