% example file
clc
clear
format long g
load("2018-12-09 11-18-10.tlog.mat")

plot(x_mavlink_local_position_ned_t(:,2),y_mavlink_local_position_ned_t(:,2))

%% plot pitch
t = datetime(pitch_mavlink_ahrs2_t(:,1),'ConvertFrom','datenum');
plot(t,pitch_mavlink_ahrs2_t(:,2)*180/pi)