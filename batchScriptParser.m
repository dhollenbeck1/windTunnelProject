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
    figure
    for j=1:length(P)
        % missing data
        if j == 2 && i == 2         % R20 P20
            continue
        end
        
        if j == 4 && i == 2         % R20 P-10
            continue
        end
        
        % F1 - FT205
        % create fn
        s3 = ['P',num2str(P(j))];
        fn = [s11,s2,s3,s4,s5];
        
        % parse data
        [t1,ws,wd] = parseFT205(fn,day,month,year,-7);
        u1 = -ws.*sind(wd);
        v1 = -ws.*cosd(wd);
        
        % save
        u_avg_f1(i,j) = mean(u1);
        v_avg_f1(i,j) = mean(v1);
        ws_avg_f1(i,j) = sqrt( u_avg_f1(i,j)^2 + v_avg_f1(i,j)^2 );
        wd_avg_f1(i,j) = atan2d( v_avg_f1(i,j) , u_avg_f1(i,j) );
        
        % F3 - FT742
        % create fn
        s3 = ['P',num2str(P(j))];
        fn = [s12,s2,s3,s4,s5];
        
        % parse data
        [t2,ws,wd] = parseFT742(fn,day,month,year,-7);
        
        % rotate data
        u2 = -ws.*sind(wd);
        v2 = -ws.*cosd(wd);
        [u2,v2,w2] = rotateMeasurement(u2,v2,P(j),R(i));
        u2 = u2./cosd(R(i));
        v2 = v2./cosd(P(j));
        
        % save
        u_avg_f3(i,j) = mean(u2);
        v_avg_f3(i,j) = mean(v2);
        ws_avg_f3(i,j) = sqrt( u_avg_f3(i,j)^2 + v_avg_f3(i,j)^2 );
        wd_avg_f3(i,j) = atan2d( v_avg_f3(i,j) , u_avg_f3(i,j) );
        
        % error
        err_ws_avg(i,j) = abs( (ws_avg_f1(i,j) - ws_avg_f3(i,j))/ ws_avg_f1(i,j) );
        err_wd_avg(i,j) = abs( (wd_avg_f1(i,j) - wd_avg_f3(i,j))/ wd_avg_f1(i,j) );
        
        % plot data
        %        subplot(6,3,(i-1)*length(P) + j)
        subplot(3,2,j)
%         plot(t1,u1,'b',t1,v1,'b--'); 
%         plot(t2,u2,'g',t2,v2,'g--'); 
        yyaxis left
        plot(t1,sqrt(u1.^2+v1.^2),'k');hold on;
        plot(t2,sqrt(u2.^2+v2.^2),'r'); hold off; 
%         ylim([-5,5])
        ylabel('m/s');
        
        yyaxis right
        plot(t1,atan2d(v1,u1),'k--'); hold on
        plot(t2,atan2d(v2,u2),'r--'); hold off
%         ylim([-5,5])
        ylabel('deg');
        
        xlabel('Time');  
        title(['P = ',num2str(P(j)),', R = ',num2str(R(i))]);
        
        % clear data
        clear u1 v1 u2 v2 w2
    end
end

save FT_test0 u_avg_f1 u_avg_f3 v_avg_f1 v_avg_f3 ws_avg_f1 ws_avg_f3 wd_avg_f1 wd_avg_f3 err_ws_avg err_wd_avg

