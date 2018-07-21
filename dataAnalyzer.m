%% Script to process the data
clc
clear
load FT_test0.mat
%%
% index =   1   2   3   4   5   6   7
% pitch =   30  20  10  0   -10 -20 -30
% roll =    0   10  20  30

% ALL MATRIX STORED AS: (roll,pitch)

% choose index
p = 4;
r = 1; 

% get wind speed and plot
subplot 121
wsc = sqrt(squeeze(uc(r,p,:)).^2 + squeeze(vc(r,p,:)).^2 );
wsm = sqrt(squeeze(um(r,p,:)).^2 + squeeze(vm(r,p,:)).^2 + squeeze(wm(r,p,:)).^2);
plot(wsc); hold on
plot(wsm/cosd(P(p))+ws_cf); hold off

% get wind direction and plot 
subplot 122
wdc = atan2d(squeeze(vc(r,p,:)),squeeze(uc(r,p,:)));
wdm = 90-atan2d(squeeze(vm(r,p,:)),squeeze(um(r,p,:)));
plot(wdc); hold on
plot(wdm+wd_cf); hold off
clear wsm wsc
%%
figure
for i=1:length(R)
    for j=1:length(P)
        wsm(i,j) = (mean(um(i,j,:))^2 + mean(vm(i,j,:)).^2 + mean(wm(i,j,:)).^2).^0.5 + ws_cf;
        wsc(i,j) = (mean(uc(i,j,:)).^2 + mean(vc(i,j,:))^2).^0.5;
    end
end
wsc(3,2) = wsc(2,2);
wsc(3,5) = wsc(2,5);
wsm(3,2) = wsm(2,2);
wsm(3,5) = wsm(2,5);

err = abs(wsm'-wsc')./wsc';
[xx,yy] = meshgrid(R,P);
% subplot 121
contourf(xx,yy,err,20)
xlabel('Roll, deg')
ylabel('Pitch, deg')
title('Percent Error vs Roll & Pitch')
colorbar
% subplot 122
% contourf(xx,yy,err_wd_avg')