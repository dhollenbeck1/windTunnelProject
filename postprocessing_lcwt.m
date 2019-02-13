%% Post processing LCWT Data
%======================================
% By Derek Hollenbeck
% updated: 2.1.19

%       Algorithm
% 1. Load in LCWT data
% 2. Find calibration values from ref data
% 3. Create calibration map to correct
% 4. Process test data
% 5. Check error map
% 6. plot anything else relevant

clc
clear

plot_tilt = 0;
plot_smap = 0;
plotTest = 0;
plot_dir = 1;

correct_tilt = 0;
correct_p = 1;
correct_r = 1;

load lcwt_data.mat

% reference parameters
R = [0,10,20,30];
P = [30,20,10,0,-10,-20,-30];

% test parameters
Rt = [0,5,10,15];
Pt = [15,10,5,0,-5,-10,-15];

lenr = length(R);
lenp = length(P);

% grid parameters and matrices
X = linspace(R(1),R(end),7)';
% Y = linspace(P(1),P(end),13)';
Y = linspace(P(end),P(1),13)';
[X,Y] = meshgrid(X,Y);
[Xr,Yr] = meshgrid(R,(-1)*P);
[Xrt,Yrt] = meshgrid(Rt,Pt);

% get actual parameters
fn = 'C:/Users/drkfr/Desktop/Wind/Data/TestingNotes.csv';
realparam = importdata(fn,',');

% update actual params
for i=1:lenr
    for j=1:lenp
        p(i,j) = realparam.data(j+(i-1)*lenp,4);
        r(i,j) = realparam.data(j+(i-1)*lenp,3);
    end
end

if correct_p == 1
    p = p*(-1);
end
%% calibration data
% get average values for each point in map
for i=1:lenr
    for j=1:lenp
        % calculate avg's
        wsf1_avg(i,j) = mean(ref(i,j,1).data(:,1));
        wsf3_avg(i,j) = mean(ref(i,j,2).data(:,1));
        uf1(i,j,:) = sind(ref(i,j,1).data(:,2));
        uf3(i,j,:) = sind(ref(i,j,2).data(:,2));
        vf1(i,j,:) = cosd(ref(i,j,1).data(:,2));
        vf3(i,j,:) = cosd(ref(i,j,2).data(:,2));
        uf1_avg(i,j) = mean(uf1(i,j,:));
        uf3_avg(i,j) = mean(uf3(i,j,:));
        vf1_avg(i,j) = mean(vf1(i,j,:));
        vf3_avg(i,j) = mean(vf3(i,j,:));
        wdf1_avg(i,j) = atan2d(mean(vf1(i,j,:)),mean(uf1(i,j,:)));
        wdf3_avg(i,j) = atan2d(mean(vf3(i,j,:)),mean(uf3(i,j,:)));
        
        % calculate tilt
        tilt(i,j) = acosd(dot([0,0,1],cross([cosd(r(i,j)),0,-sind(r(i,j))],[0,cosd(p(i,j)),-sind(p(i,j))])));
        
        % rotate measurements
        
        % correct flow turning due to expansion
        
        % calculate correction factor.
        
    end
end

if correct_r == 1
    wsf3_avg = reorderData(wsf3_avg,lenr,lenp);
    wsf1_avg = reorderData(wsf1_avg,lenr,lenp);
end

% interpolate to include points for comparison with test data
Z1 = interp2(Xr,Yr,wsf1_avg',X,Y);
Z3 = interp2(Xr,Yr,wsf3_avg',X,Y);

%% Test data
% Note: F1 is actually on-board measurement not control (this data set)

for i=1:lenr
    for j=1:lenp
        s = [num2str(i),num2str(j)];
        if strcmp(s,'31') || strcmp(s,'41') || strcmp(s,'42') || strcmp(s,'37')|| strcmp(s,'47')|| strcmp(s,'46')
            continue
        end
        
        % calculate avg's
        wsf1t_avg(i,j) = mean(test(i,j,1).data(:,1));
        wsf3t_avg(i,j) = mean(test(i,j,2).data(:,1));
        uf1t(i,j,:) = mean(sind(test(i,j,1).data(:,2)));
        uf3t(i,j,:) = mean(sind(test(i,j,2).data(:,2)));
        vf1t(i,j,:) = mean(cosd(test(i,j,1).data(:,2)));
        vf3t(i,j,:) = mean(cosd(test(i,j,2).data(:,2)));
        uf1t_avg(i,j) = mean(uf1t(i,j,:));
        uf3t_avg(i,j) = mean(uf3t(i,j,:));
        vf1t_avg(i,j) = mean(vf1t(i,j,:));
        vf3t_avg(i,j) = mean(vf3t(i,j,:));
        wdf1t_avg(i,j) = atan2d(vf1t(i,j,:),uf1t(i,j,:));
        wdf3t_avg(i,j) = atan2d(vf3t(i,j,:),uf3t(i,j,:));
        
        % calculate tilt
        %         tiltt(i,j) = acosd(dot([0,0,1],cross([cosd(r(i,j)),0,-sind(r(i,j))],[0,cosd(p(i,j)),-sind(p(i,j))])));
        
        % rotate measurements
        
        % correct flow turning due to expansion
        
        % calculate correction factor.
        
    end
end
%% Plotting

if plotTest == 1
    subplot 121
    ind = find(wsf1t_avg==0);
    wsf1t_avg(ind) = mean(mean(wsf1t_avg(find(wsf1t_avg~=0))));
    [C,h] = contourf(Xrt',Yrt',wsf1t_avg);
    clabel(C,h);
    %     surf(Xrt',Yrt',abs(wsf1t_avg-wsf3t_avg)./wsf1t_avg);
    %     surf(Xrt',Yrt',abs(wsf1t_avg-wsf3t_avg)./wsf1t_avg);
    %     axis([R(1),R(end),P(end),P(1),0,5])
    
    subplot 122
    [C,h] = contourf(Xrt',Yrt',wsf3t_avg);
    clabel(C,h);
end

if plot_smap == 1
    figure
    
    subplot 121
    surf(X,Y,Z1);axis([R(1),R(end),P(end),P(1),2,4])
    title('Control Measurement with Throttle off')
    colorbar('Ticks',[2.5,2.9,3.4],...
        'TickLabels',{'2.5m/s','2.9m/s','3.4m/s'})
    xlabel('Roll'); ylabel('Pitch'); zlabel('Wind Speed');
    
    subplot 122
    surf(X,Y,Z3);axis([R(1),R(end),P(end),P(1),2,4])
    title('On-board Measurement with Throttle off')
    colorbar('Ticks',[2.5,2.9,3.4],...
        'TickLabels',{'2.5m/s','2.9m/s','3.4m/s'})
    xlabel('Roll'); ylabel('Pitch'); zlabel('Wind Speed');
    
end


% correct ws magnitude for tilt
if plot_tilt == 1
    figure
    %     subplot 221
    %     plot3(r,p,wsf3_avg,'r'); hold on
    %     plot3(r,p,wsf1_avg,'k'); hold off
    %     axis([R(1),R(end),P(end),P(1),0,5])
    
    subplot 221
    surf(r,p,abs(wsf1_avg-wsf3_avg)./wsf1_avg);
    axis([R(1),R(end),P(end),P(1),0,0.2])
    title('Error before tilt compensation')
    colorbar('Ticks',[0,0.1,0.2],...
        'TickLabels',{'no error','acceptable error','no good'})
    xlabel('Roll'); ylabel('Pitch'); zlabel('%error');
    %     [C,h] = contour(r,p,abs(wsf1_avg-wsf3_avg)./wsf1_avg);
    %     clabel(C,h);
    %     axis([R(1),R(end),P(end),P(1)])
    
    wsf3_avg = wsf3_avg./cosd(tilt);
    %     subplot 223
    %     plot3(r,p,wsf1_avg,'k'); hold on
    %     plot3(r,p,wsf3_avg,'r'); hold off
    %     axis([R(1),R(end),P(end),P(1),0,5])
    
    subplot 222
    surf(r,p,abs(wsf1_avg-wsf3_avg)./wsf1_avg);
    axis([R(1),R(end),P(end),P(1),0,0.2])
    title('Error after tilt compensation')
    colorbar('Ticks',[0,0.1,0.2],...
        'TickLabels',{'no error','acceptable error','no good'})
    xlabel('Roll'); ylabel('Pitch'); zlabel('%error');
    %     [C,h] = contour(r,p,abs(wsf1_avg-wsf3_avg)./wsf1_avg);
    %     clabel(C,h);
    %     axis([R(1),R(end),P(end),P(1)])
    
    subplot 223
    surf(r,p,tilt)
end
%         surf(r,p,tilt)
if plot_smap == 1
    figure
    
    Z1 = interp2(Xr,Yr,wsf1_avg',X,Y);
    Z3 = interp2(Xr,Yr,wsf3_avg',X,Y);
    
    subplot 121
    surf(X,Y,Z1);axis([R(1),R(end),P(end),P(1),2,4])
    title('Control Measurement with Throttle off')
    colorbar('Ticks',[2.5,2.9,3.4],...
        'TickLabels',{'2.5m/s','2.9m/s','3.4m/s'})
    xlabel('Roll'); ylabel('Pitch'); zlabel('Wind Speed')
    
    subplot 122
    surf(X,Y,Z3);axis([R(1),R(end),P(end),P(1),2,4])
    title('On-board Measurement with Throttle off')
    colorbar('Ticks',[2.5,2.9,3.4],...
        'TickLabels',{'2.5m/s','2.9m/s','3.4m/s'})
    xlabel('Roll'); ylabel('Pitch'); zlabel('Wind Speed')
end

if plot_dir == 1
    yaw_correction1 = 0;
    wd_correction1 = 0;
    yaw_correction2 = 0;
    wd_correction2 = 0;
    
    subplot 231
    [C,h] = contourf(Xr,Yr,wdf1_avg');
    clabel(C,h);
    title('control: no throttle'); %axis([0,15,-15,15])
    xlabel('roll'); ylabel('pitch');
    
    subplot 232
    [C,h] = contourf(Xr,Yr,wdf3_avg'-wd_correction1,20);
    clabel(C,h);
    title('onboard: no throttle'); %axis([0,15,-15,15])
    xlabel('roll'); ylabel('pitch');
    
    subplot 233
    for i=1:lenr
        for j=1:lenp
            [u,v,w] = rotateMeasurement(uf3(i,j),vf3(i,j),P(j),R(i),yaw_correction1);
            rot(i,j) = atan2d(v,u);
        end
    end
    %         [C,h] = contourf(Xrt,Yrt,(rot'-wdf1_avg')./wdf1_avg');
    [C,h] = contourf(Xr,Yr,rot'-wd_correction1,20);
    clabel(C,h);
    title('onboard: no throttle: corrected'); %axis([0,15,-15,15])
    xlabel('roll'); ylabel('pitch');
    
    subplot 234
    [C,h] = contourf(Xrt,Yrt,wdf1t_avg');
    clabel(C,h);
    title('control: throttle');
    xlabel('roll'); ylabel('pitch');
    
    subplot 235
    [C,h] = contourf(Xrt,Yrt,wdf3t_avg'-wd_correction2);
    clabel(C,h);
    title('onboard: throttle:');
    xlabel('roll'); ylabel('pitch');
    
    subplot 236
    for i=1:lenr
        for j=1:lenp
            [u,v,w] = rotateMeasurement(uf3t(i,j),vf3t(i,j),Pt(j),Rt(i),yaw_correction2);
            rot(i,j) = atan2d(v,u);
        end
    end
    %         [C,h] = contourf(Xrt,Yrt,(rot'-wdf1_avg')./wdf1_avg');
    [C,h] = contourf(Xrt,Yrt,rot'-wd_correction2);
    clabel(C,h);
    title('onboard: throttle: corrected');
    xlabel('roll'); ylabel('pitch');
    
    
    
    
    
    %     ,p,wdf3_avg)
end

% [pp,rr] = meshgrid(p,r);
% contour(p,r,(wsf3_avg-wsf1_avg)./wsf1_avg,10);

%% old code
% s11 = 'F1_';
% s12 = 'F3_';
% s4 = 'T0';
% s5 = '_Test0.txt';
%
% % initialize matrix for storing data
% um = zeros(length(R),length(P),sampleSize);
% uc = um;
% vm = um;
% vc = um;
%
% for i=1:length(R)
%     s2 = ['R',num2str(R(i))];
%     figure
%     for j=1:length(P)
%         % missing data
%         %         if i == 1
%         %            if j ~= 4
%         %               continue
%         %            end
%         %         end
%         %
%         %         if i~= 1
%         %             if j == 4
%         %                 continue
%         %             end
%         %         end
%
%         if j == 2 && i == 3         % R20 P20
%             continue
%         end
%
%         if j == 5 && i == 3         % R20 P-10
%             continue
%         end
%
%         % F1 - FT205
%         % create fn
%         s3 = ['P',num2str(P(j))];
%         fn = [s11,s2,s3,s4,s5];
%
%         % parse data
%         [t1,ws,wd] = parseFT205(fn,day,month,year,-7);
%
%         % take sample size from set
%         t1 = t1(sampleStart:sampleStart+sampleSize-1);
%         ws = ws(sampleStart:sampleStart+sampleSize-1);
%         wd = wd(sampleStart:sampleStart+sampleSize-1);
%
%         % get components
%         u1 = ws.*cosd(wd);
%         v1 = ws.*sind(wd);
%
%         % get mean windspeed and direction for correction
%         control_ws = mean(ws);
%         control_wd = mean(wd);
%
%         % save
%         uc(i,j,:) = u1;
%         vc(i,j,:) = v1;
%         u_avg_f1(i,j) = mean(u1);
%         v_avg_f1(i,j) = mean(v1);
%         ws_avg_f1(i,j) = sqrt( u_avg_f1(i,j)^2 + v_avg_f1(i,j)^2 );
%         wd_avg_f1(i,j) = atan2d( v_avg_f1(i,j) , u_avg_f1(i,j) );
%
%         % F3 - FT742
%         % create fn
%         s3 = ['P',num2str(P(j))];
%         fn = [s12,s2,s3,s4,s5];
%
%         % parse data
%         [t2,ws,wd] = parseFT742(fn,day,month,year,-7);
%
%         % take sample size from set
%         t2 = t2(sampleStart:sampleStart+sampleSize-1);
%         ws = ws(sampleStart:sampleStart+sampleSize-1);
%         wd = wd(sampleStart:sampleStart+sampleSize-1);
%
%         % get correction data
%         measure_ws = mean(ws);
%         measure_wd = mean(wd);
%
%         % rotate data
%         u2 = ws.*sind(wd);
%         v2 = ws.*cosd(wd);
%         [u2,v2,w2] = rotateMeasurement(u2,v2,P(j),R(i));
%
%         % save
%         um(i,j,:) = u2;
%         vm(i,j,:) = v2;
%         wm(i,j,:) = w2;
%         u_avg_f3(i,j) = mean(u2);
%         v_avg_f3(i,j) = mean(v2);
%         ws_avg_f3(i,j) = sqrt( u_avg_f3(i,j)^2 + v_avg_f3(i,j)^2 );
%         wd_avg_f3(i,j) = atan2d( v_avg_f3(i,j) , u_avg_f3(i,j) );
%
%         % error
%         err_ws_avg(i,j) = abs( (ws_avg_f1(i,j) - ws_avg_f3(i,j))/ ws_avg_f1(i,j) );
%         err_wd_avg(i,j) = abs( (wd_avg_f1(i,j) - wd_avg_f3(i,j))/ wd_avg_f1(i,j) );
%
%         if i==1 && j ==4
%             ws_cf = control_ws - measure_ws;
%             ku = mean(u1)/mean(u2)
%             kv = mean(v1)/mean(v2)
%             wd_cf = control_wd - measure_wd;
%         end
%
%         % plot data
%         %        subplot(6,3,(i-1)*length(P) + j)
%         subplot(4,2,j)
%         %         plot(t1,u1,'b',t1,v1,'b--');
%         %         plot(t2,u2,'g',t2,v2,'g--');
%         yyaxis left
%         plot(t1,sqrt(u1.^2+v1.^2),'r--');hold on;
%         plot(t2,sqrt(u2.^2+v2.^2),'r'); hold off;
%         ylim([0,5])
%         ylabel('m/s');
%
%         yyaxis right
%         plot(t1,atan2d(v1,u1),'k--'); hold on
%         plot(t2,atan2d(v2,u2),'k'); hold off
%         %         ylim([-5,5])
%         ylabel('deg');
%
%         xlabel('Time');
%         title(['P = ',num2str(P(j)),', R = ',num2str(R(i))]);
%
%         % clear data
%         kval(i,j,1) = mean(u1)/mean(u2);
%         kval(i,j,2) = mean(v1)/mean(v2);
%
%         clear u1 v1 u2 v2 w2
%     end
% end
%
% save FT_test0 u_avg_f1 u_avg_f3 v_avg_f1 ...
%     v_avg_f3 ws_avg_f1 ws_avg_f3 wd_avg_f1 ...
%     wd_avg_f3 err_ws_avg err_wd_avg...
%     P R ws_cf wd_cf um uc vm vc wm kval

%% FUNCTIONS
function dataout = reorderData(datain,lenr,lenp)
temp = zeros(lenr,lenp);
for i=1:4
    temp(i,:) = datain(end-i+1,:);
end
dataout = temp;
clear temp
end