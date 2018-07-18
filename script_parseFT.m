%   FT Parser
% ===================
% reads in raw FT data and outputs to mat file
%% Clear old data
clc 
clear all
%% Settings
day = 09;
month = 07;
year = 2018;
timezoneshift = -7;
fn = "F1_R30P0T0_Test0.txt";
%% Get Parsed Data
[t_f1,ws_f1,wd_f1] = parseFT205(fn,day,month,year,timezoneshift);
[t_f3,ws_f3,wd_f3] = parseFT742(fn,day,month,year,timezoneshift);
%% plot
subplot 211
plot(t_f1,ws_f1,'r');
subplot 212 
plot(t_f1,wd_f1,'b');
plot(t_f1,'o')
% t(1:35)