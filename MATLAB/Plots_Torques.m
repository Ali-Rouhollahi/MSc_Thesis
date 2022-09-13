close all

indx = 150;
q.FR =  rem(FR.q.Data(indx:end),2*pi);
temp = q.FR(1);
indx_lst = [];
for j = 2:size(q.FR)
    if temp > q.FR(j)
      indx_lst=[indx_lst;j];  
    end
    temp = q.FR(j);
end


tau.FR.r = FR.tau_r.Data(indx:end);
tau.FR.a = FR.tau_a.Data(indx:end);
tau.FR.c = FR.tau_c.Data(indx:end);
q.FR = q.FR(indx_lst(1):indx_lst(2)-1);
tau.FR.r = tau.FR.r(indx_lst(1):indx_lst(2)-1);
tau.FR.a = tau.FR.a(indx_lst(1):indx_lst(2)-1);
tau.FR.c = tau.FR.c(indx_lst(1):indx_lst(2)-1);

q.FL =  rem(FL.q.Data(indx:end),2*pi);
temp = q.FL(1);
indx_lst = [];
for j = 2:size(q.FL)
    if temp > q.FL(j)
      indx_lst=[indx_lst;j];  
    end
    temp = q.FL(j);
end
tau.FL.r = FL.tau_r.Data(indx:end);
tau.FL.a = FL.tau_a.Data(indx:end);
tau.FL.c = FL.tau_c.Data(indx:end);
q.FL = q.FL(indx_lst(1):indx_lst(2)-1);
tau.FL.r = tau.FL.r(indx_lst(1):indx_lst(2)-1);
tau.FL.a = tau.FL.a(indx_lst(1):indx_lst(2)-1);
tau.FL.c = tau.FL.c(indx_lst(1):indx_lst(2)-1);

q.BR =  rem(BR.q.Data(indx:end),2*pi);
temp = q.BR(1);
indx_lst = [];
for j = 2:size(q.BR)
    if temp > q.BR(j)
      indx_lst=[indx_lst;j];  
    end
    temp = q.BR(j);
end
tau.BR.r = BR.tau_r.Data(indx:end);
tau.BR.a = BR.tau_a.Data(indx:end);
tau.BR.c = BR.tau_c.Data(indx:end);
q.BR = q.BR(indx_lst(1):indx_lst(2)-1);
tau.BR.r = tau.BR.r(indx_lst(1):indx_lst(2)-1);
tau.BR.a = tau.BR.a(indx_lst(1):indx_lst(2)-1);
tau.BR.c = tau.BR.c(indx_lst(1):indx_lst(2)-1);

q.BL =  rem(BL.q.Data(indx:end),2*pi);
temp = q.BL(1);
indx_lst = [];
for j = 2:size(q.BL)
    if temp > q.BL(j)
      indx_lst=[indx_lst;j];  
    end
    temp = q.BL(j);
end
tau.BL.r = BL.tau_r.Data(indx:end);
tau.BL.a = BL.tau_a.Data(indx:end);
tau.BL.c = BL.tau_c.Data(indx:end);
q.BL = q.BL(indx_lst(1):indx_lst(2)-1);
tau.BL.r = tau.BL.r(indx_lst(1):indx_lst(2)-1);
tau.BL.a = tau.BL.a(indx_lst(1):indx_lst(2)-1);
tau.BL.c = tau.BL.c(indx_lst(1):indx_lst(2)-1);

figure;
plot(q.FR, tau.FR.r,'k-','LineWidth',1)
hold on
plot(q.FR, tau.FR.c,'b--','LineWidth',1)
hold on
plot(q.FR, tau.FR.a,'r-','LineWidth',1)
legend('t_{r}','t_{c}','t_{a}')
grid on
title('FR')
ylabel('Torque[N.m]')
xlabel('\phi (rad)')
xticks([0 pi/2 pi 3*pi/2 2*pi])
set(gca, 'TickLabelInterpreter', 'latex', 'XTickLabel', {'$0$','$\frac{\pi}{2}$','$\pi$','$\frac{3\pi}{2}$','$2\pi$'})


figure;
plot(q.FL,tau.FL.r,'k-','LineWidth',1)
hold on
plot(q.FL,tau.FL.c,'b--','LineWidth',1)
hold on
plot(q.FL,tau.FL.a,'r-','LineWidth',1)
legend('t_{r}','t_{c}','t_{a}')
grid on
title('FL')
ylabel('Torque[N.m]')
xlabel('\phi (rad)')
xticks([0 pi/2 pi 3*pi/2 2*pi])
set(gca, 'TickLabelInterpreter', 'latex', 'XTickLabel', {'$0$','$\frac{\pi}{2}$','$\pi$','$\frac{3\pi}{2}$','$2\pi$'})


figure;
plot(q.BR,tau.BR.r,'k-','LineWidth',1)
hold on
plot(q.BR,tau.BR.c,'b--','LineWidth',1)
hold on
plot(q.BR,tau.BR.a,'r-','LineWidth',1)
legend('t_{r}','t_{c}','t_{a}')
grid on
title('BR')
ylabel('Torque[N.m]')
xlabel('\phi (rad)')
xticks([0 pi/2 pi 3*pi/2 2*pi])
set(gca, 'TickLabelInterpreter', 'latex', 'XTickLabel', {'$0$','$\frac{\pi}{2}$','$\pi$','$\frac{3\pi}{2}$','$2\pi$'})


figure;
plot(q.BL,tau.BL.r,'k-','LineWidth',1)
hold on
plot(q.BL,tau.BL.c,'b--','LineWidth',1)
hold on
plot(q.BL,tau.BL.a,'r-','LineWidth',1)
legend('t_{r}','t_{c}','t_{a}')
grid on
title('BL')
ylabel('Torque[N.m]')
xlabel('\phi (rad)')
xticks([0 pi/2 pi 3*pi/2 2*pi])
set(gca, 'TickLabelInterpreter', 'latex', 'XTickLabel', {'$0$','$\frac{\pi}{2}$','$\pi$','$\frac{3\pi}{2}$','$2\pi$'})