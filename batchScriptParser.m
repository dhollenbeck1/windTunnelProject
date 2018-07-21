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
sampleStart = 200;
sampleSize = 2400;

% test parameters
R = linspace(0,30,4);
P = [30,20,10,0,-10,-20,-30];

s11 = 'F1_';
s12 = 'F3_';
s4 = 'T0';
s5 = '_Test0.txt';

% initialize matrix for storing data
um = zeros(length(R),length(P),sampleSize);
uc = um;
vm = um; 
vc = um;

for i=1:length(R)
    s2 = ['R',num2str(R(i))];
    figure
    for j=1:length(P)
        % missing data
%         if i == 1
%            if j ~= 4
%               continue
%            end
%         end
%         
%         if i~= 1
%             if j == 4
%                 continue
%             end
%         end
        
        if j == 2 && i == 3         % R20 P20
            continue
        end
        
        if j == 5 && i == 3         % R20 P-10
            continue
        end
        
        % F1 - FT205
        % create fn
        s3 = ['P',num2str(P(j))];
        fn = [s11,s2,s3,s4,s5];
        
        % parse data
        [t1,ws,wd] = parseFT205(fn,day,month,year,-7);
        
        % take sample size from set
        t1 = t1(sampleStart:sampleStart+sampleSize-1);
        ws = ws(sampleStart:sampleStart+sampleSize-1);
        wd = wd(sampleStart:sampleStart+sampleSize-1);
        
        % get components
        u1 = ws.*cosd(wd);
        v1 = ws.*sind(wd);
        
        % get mean windspeed and direction for correction
        control_ws = mean(ws);
        control_wd = mean(wd);
        
        % save
        uc(i,j,:) = u1;
        vc(i,j,:) = v1;     
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
        
        % take sample size from set
        t2 = t2(sampleStart:sampleStart+sampleSize-1);
        ws = ws(sampleStart:sampleStart+sampleSize-1);
        wd = wd(sampleStart:sampleStart+sampleSize-1);
        
        % get correction data
        measure_ws = mean(ws);
        measure_wd = mean(wd);
        
        % rotate data
        u2 = ws.*sind(wd);
        v2 = ws.*cosd(wd);
        [u2,v2,w2] = rotateMeasurement(u2,v2,P(j),R(i));
        
        % save
        um(i,j,:) = u2;
        vm(i,j,:) = v2;
        wm(i,j,:) = w2;
        u_avg_f3(i,j) = mean(u2);
        v_avg_f3(i,j) = mean(v2);
        ws_avg_f3(i,j) = sqrt( u_avg_f3(i,j)^2 + v_avg_f3(i,j)^2 );
        wd_avg_f3(i,j) = atan2d( v_avg_f3(i,j) , u_avg_f3(i,j) );
        
        % error
        err_ws_avg(i,j) = abs( (ws_avg_f1(i,j) - ws_avg_f3(i,j))/ ws_avg_f1(i,j) );
        err_wd_avg(i,j) = abs( (wd_avg_f1(i,j) - wd_avg_f3(i,j))/ wd_avg_f1(i,j) );
        
        if i==1 && j ==4
            ws_cf = control_ws - measure_ws;
            ku = mean(u1)/mean(u2)
            kv = mean(v1)/mean(v2)
            wd_cf = control_wd - measure_wd;
        end
        
        % plot data
        %        subplot(6,3,(i-1)*length(P) + j)
        subplot(4,2,j)
%         plot(t1,u1,'b',t1,v1,'b--'); 
%         plot(t2,u2,'g',t2,v2,'g--'); 
        yyaxis left
        plot(t1,sqrt(u1.^2+v1.^2),'r--');hold on;
        plot(t2,sqrt(u2.^2+v2.^2),'r'); hold off; 
        ylim([0,5])
        ylabel('m/s');
        
        yyaxis right
        plot(t1,atan2d(v1,u1),'k--'); hold on
        plot(t2,atan2d(v2,u2),'k'); hold off
%         ylim([-5,5])
        ylabel('deg');
        
        xlabel('Time');  
        title(['P = ',num2str(P(j)),', R = ',num2str(R(i))]);
        
        % clear data
        kval(i,j,1) = mean(u1)/mean(u2);
        kval(i,j,2) = mean(v1)/mean(v2);
        
        clear u1 v1 u2 v2 w2
    end
end

save FT_test0 u_avg_f1 u_avg_f3 v_avg_f1 ...
    v_avg_f3 ws_avg_f1 ws_avg_f3 wd_avg_f1 ...
    wd_avg_f3 err_ws_avg err_wd_avg...
    P R ws_cf wd_cf um uc vm vc wm kval

