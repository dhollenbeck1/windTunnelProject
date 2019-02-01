% Madoka Oyama
% Fall 2018 ME 195 1.0 Unit
% MESA Lab Research with Derek Hollenbeck, Dr. Yang Quan Chen

clc
clear
format long g
load('2018-12-09 11-18-10.tlog.mat')
% load('2018-12-09 10-19-50.tlog.mat')
% addpath C:\Users\Madoka\Documents\MESA\ThrottleTests\F1_Throttle
% addpath C:\Users\Madoka\Documents\MESA\ThrottleTests\F3_Throttle
%%
% converting from serial date number to datetime
% t = datetime(pitch_mavlink_ahrs2_t(:,1), 'ConvertFrom', 'datenum');
t = pitch_mavlink_ahrs2_t(:,1);
x = pitch_mavlink_ahrs2_t(:,2)*180/pi;


figure(1)
% plot(t, x);
n = 100; len = length(x);
tt = linspace(t(1),t(end),n);
xx = resample(x,tt);
plot(t,x,tt,xx)
%spline stuff that doesn't work:
%xx = t(1):t(end);
%yy = spline(t, pitch_mavlink_ahrs2_t(:,2)*180/pi, xx);
%plot(t, pitch_mavlink_ahrs2_t(:,2)*180/pi, 'o', xx, yy);
%%
hold on
plot(t, roll_mavlink_ahrs2_t(:,2)*180/pi);
hold on
plot(t, yaw_mavlink_ahrs2_t(:,2)*180/pi);
legend('pitch', 'roll', 'yaw');

% rotation
% roll = phi, pitch = theta, yaw = ksi, wind direction = lambda
theta = pitch_mavlink_ahrs2_t(:,2)*180/pi;
phi = roll_mavlink_ahrs2_t(:,2)*180/pi;
ksi = yaw_mavlink_ahrs2_t(:,2)*180/pi;

tilt = acos(cos(theta).*cos(phi));
lambda = atan((-sin(phi).*cos(theta))./(cos(phi).*cos(theta)))+180;
