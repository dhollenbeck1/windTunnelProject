%% Batch script 
% parses all of the test files and outputs to mat file
%% Clear data
clc 
clear
%% Add the paths
addpath C:/Users/drkfr/Desktop/Wind/WindTestF1F3_Sum18/F1_Test0_NoThrottle/
addpath C:/Users/drkfr/Desktop/Wind/WindTestF1F3_Sum18/F3_Test0_NoThrottle/
%% Load each file
% roll = R
% pitch = P
% roll values {10,20,30}
% pitch values [-30,30] in increments of 10

% settings
day = 17;
month = 7;
year = 2018;

% test parameters
R = linspace(10,30,3);
P = [30,20,10,-10,-20,-30];

s11 = 'F1_';
s12 = 'F3_';
s4 = 'T0';
s5 = '_Test0.txt';

for i=1:length(R)
    s2 = ['R',num2str(R(i))];
    for j=1:length(P)
        if j == 2 && i == 2
            continue
        end
        
        if j == 3 && i == 2
            continue
        end
        j
        % F1 - FT205       
        % create fn
        s3 = ['P',num2str(P(j))];
        fn = [s11,s2,s3,s4,s5];
        
        % parse data
        [t,ws,wd] = parseFT205(fn,day,month,year,-7);
        u = ws.*cosd(wd);
        v = ws.*sind(wd);
        
        % save
        u_avg_f1(i,j) = mean(u);
        v_avg_f1(i,j) = mean(v);
        
                % F1 - FT742       
        % create fn
        s3 = ['P',num2str(P(j))];
        fn = [s12,s2,s3,s4,s5];
        
        % parse data
        [t,ws,wd] = parseFT742(fn,day,month,year,-7);
        
        % rotate data
        u = ws.*cosd(wd);
        v = ws.*sind(wd);
        w = zeros(length(u));
        [u,v,w] = rotateMeasurement(u,v,P(j),R(i));
        
        % save
        u_avg_f3(i,j) = mean(u);
        v_avg_f3(i,j) = mean(v);
        
        % error
        err_avg(i,j) = abs( (u_avg_f1(i,j) - u_avg_f3(i,j))/ u_avg_f1(i,j) );
    end
end

save FT_test0 u_avg_f1 u_avg_f3 v_avg_f1 v_avg_f3 err_avg

