clearvars -except FR FL BR BL
clc
%% FR
indx = 150;
q = FR.q.Data(indx:end);
tau_r = FR.tau_r.Data(indx:end);
w = FR.w.Data(indx:end);
t = FR.q.Time(indx:end);

q = rem(q,2*pi);
temp = q(1);
indx_lst = [];
for j = 2:size(q)
    if temp > q(j)
      indx_lst = [indx_lst;j];  
    end
    temp = q(j);
end
% disp(i)
q = q(indx_lst(1):indx_lst(2)-1);
t = t(indx_lst(1):indx_lst(2)-1) - min(t);
tau_r = tau_r(indx_lst(1):indx_lst(2)-1);
w = w(indx_lst(1):indx_lst(2)-1);

plus = find(tau_r >= 0);
minus = find(tau_r < 0);
w_r_p = trapz(t(plus),w(plus).*tau_r(plus));
w_r_m = trapz(t(minus),w(minus).*tau_r(minus));
c_w = w_r_p/abs(w_r_m);
u_r_p = trapz(t(plus),w(plus).*(tau_r(plus).^2));
u_r_m = trapz(t(minus),w(minus).*(tau_r(minus).^2));
k_p = (u_r_p + c_w*u_r_m)/(u_r_p + c_w^2*u_r_m);
k_m = c_w*k_p;

tau_c = tau_r;
tau_c(plus) = k_p*tau_r(plus);
tau_c(minus) = k_m*tau_r(minus);
% check
u_c_p = trapz(t(plus),w(plus).*(tau_c(plus)));
u_c_m = trapz(t(minus),w(minus).*(tau_c(minus)));
save('FR_Spring.mat','q','tau_c')
fprintf('FR: \n')
fprintf("k_p:%.3f  k_m:%.3f \n",k_p,k_m)
fprintf("plus work:%.3f  minus work:%.3f \n",u_c_p,u_c_m)

clearvars -except FR FL BR BL

%% FL
indx = 150;
q = FL.q.Data(indx:end);
tau_r = FL.tau_r.Data(indx:end);
w = FL.w.Data(indx:end);
t = FL.q.Time(indx:end);

q = rem(q,2*pi);
temp = q(1);
indx_lst = [];
for j = 2:size(q)
    if temp > q(j)
      indx_lst = [indx_lst;j];  
    end
    temp = q(j);
end
% disp(i)
q = q(indx_lst(1):indx_lst(2)-1);
t = t(indx_lst(1):indx_lst(2)-1) - min(t);
tau_r = tau_r(indx_lst(1):indx_lst(2)-1);
w = w(indx_lst(1):indx_lst(2)-1);

plus = find(tau_r >= 0);
minus = find(tau_r < 0);
w_r_p = trapz(t(plus),w(plus).*tau_r(plus));
w_r_m = trapz(t(minus),w(minus).*tau_r(minus));
c_w = w_r_p/abs(w_r_m);
u_r_p = trapz(t(plus),w(plus).*(tau_r(plus).^2));
u_r_m = trapz(t(minus),w(minus).*(tau_r(minus).^2));
k_p = (u_r_p + c_w*u_r_m)/(u_r_p + c_w^2*u_r_m);
k_m = c_w*k_p;

tau_c = tau_r;
tau_c(plus) = k_p*tau_r(plus);
tau_c(minus) = k_m*tau_r(minus);
% check
u_c_p = trapz(t(plus),w(plus).*(tau_c(plus)));
u_c_m = trapz(t(minus),w(minus).*(tau_c(minus)));
save('FL_Spring.mat','q','tau_c')
fprintf('FL: \n')
fprintf("k_p:%.3f  k_m:%.3f \n",k_p,k_m)
fprintf("plus work:%.3f  minus work:%.3f \n",u_c_p,u_c_m)

clearvars -except FR FL BR BL
%% BL
indx = 150;
q = BL.q.Data(indx:end);
tau_r = BL.tau_r.Data(indx:end);
w = BL.w.Data(indx:end);
t = BL.q.Time(indx:end);

q = rem(q,2*pi);
temp = q(1);
indx_lst = [];
for j = 2:size(q)
    if temp > q(j)
      indx_lst = [indx_lst;j];  
    end
    temp = q(j);
end
% disp(i)
q = q(indx_lst(1):indx_lst(2)-1);
t = t(indx_lst(1):indx_lst(2)-1) - min(t);
tau_r = tau_r(indx_lst(1):indx_lst(2)-1);
w = w(indx_lst(1):indx_lst(2)-1);

plus = find(tau_r >= 0);
minus = find(tau_r < 0);
w_r_p = trapz(t(plus),w(plus).*tau_r(plus));
w_r_m = trapz(t(minus),w(minus).*tau_r(minus));
c_w = w_r_p/abs(w_r_m);
u_r_p = trapz(t(plus),w(plus).*(tau_r(plus).^2));
u_r_m = trapz(t(minus),w(minus).*(tau_r(minus).^2));
k_p = (u_r_p + c_w*u_r_m)/(u_r_p + c_w^2*u_r_m);
k_m = c_w*k_p;


tau_c = tau_r;
tau_c(plus) = k_p*tau_r(plus);
tau_c(minus) = k_m*tau_r(minus);


% check
u_c_p = trapz(t(plus),w(plus).*(tau_c(plus)));
u_c_m = trapz(t(minus),w(minus).*(tau_c(minus)));
save('BL_Spring.mat','q','tau_c')
fprintf('BL: \n')
fprintf("k_p:%.3f  k_m:%.3f \n",k_p,k_m)
fprintf("plus work:%.3f  minus work:%.3f \n",u_c_p,u_c_m)

clearvars -except FR FL BR BL

%% BR
indx = 150;
q = BR.q.Data(indx:end);
tau_r = BR.tau_r.Data(indx:end);
w = BR.w.Data(indx:end);
t = BR.q.Time(indx:end);

q = rem(q,2*pi);
temp = q(1);
indx_lst = [];
for j = 2:size(q)
    if temp > q(j)
      indx_lst = [indx_lst;j];  
    end
    temp = q(j);
end
% disp(i)
q = q(indx_lst(1):indx_lst(2)-1);
t = t(indx_lst(1):indx_lst(2)-1) - min(t);
tau_r = tau_r(indx_lst(1):indx_lst(2)-1);
w = w(indx_lst(1):indx_lst(2)-1);

plus = find(tau_r >= 0);
minus = find(tau_r < 0);
w_r_p = trapz(t(plus),w(plus).*tau_r(plus));
w_r_m = trapz(t(minus),w(minus).*tau_r(minus));
c_w = w_r_p/abs(w_r_m);
u_r_p = trapz(t(plus),w(plus).*(tau_r(plus).^2));
u_r_m = trapz(t(minus),w(minus).*(tau_r(minus).^2));
k_p = (u_r_p + c_w*u_r_m)/(u_r_p + c_w^2*u_r_m);
k_m = c_w*k_p;
tau_c = tau_r;
tau_c(plus) = k_p*tau_r(plus);
tau_c(minus) = k_m*tau_r(minus);
% check
u_c_p = trapz(t(plus),w(plus).*(tau_c(plus)));
u_c_m = trapz(t(minus),w(minus).*(tau_c(minus)));

save('BR_Spring.mat','q','tau_c')
fprintf('BR: \n')
fprintf("k_p:%.3f  k_m:%.3f \n",k_p,k_m)
fprintf("plus work:%.3f  minus work:%.3f \n",u_c_p,u_c_m)

clearvars -except FR FL BR BL
