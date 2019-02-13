%% Preprocessing VP Experiment 12/13/18
% Bt Derek Hollenbeck

% Algorithm
% 1. Import and parse Telemetry data.
%       - interpolate to fixed time interval
% 2. Import and pares wind data.
%       - Interpolate wind data to telemetry data (time)
% 4. Cut individual test sets and save their mat

% Note - everything is interpolated to telemetry start and stop time at
% 5hz. The sampling rates of telemetery and wind are around 2 hz and 10 hz,
% respectively. Thus 5 Hz seemed reasonable to interpolate to. 

clc
clear
%% Import data
for k=1:3
    
    % SETTINGS
    ref = [];test = [];
    day = 17;month = 7;year = 2018;
    s0 = 'C:/Users/drkfr/Desktop/Wind/Data';        % top directory
    s1 = ['vp_tlog';'vp_DaBD';'vp_gcsd'];
    hz = 5;
    testdata = [];
    
    switch k
        case 1
            % TELEM DATA - MAT File
            fpath = [s0,'/',s1(1,:)]; % set path
            [d,numfiles,numdir] = getfpathinfo(fpath);
            for i=1:numfiles
                
                if i==1
                    continue
                end
                temp = [];
                %load current file
                load([fpath,'/',d(i+numdir).name])
                
                % AHRS data
                lat = lat_mavlink_ahrs3_t(:,2)/1e7;                 %get lat lng data
                lng = lng_mavlink_ahrs3_t(:,2)/1e7;
                alt = altitude_mavlink_ahrs3_t(:,2);                %get altitude
                rol = roll_mavlink_ahrs3_t(:,2);                    %get pitch,roll,yaw
                pit = pitch_mavlink_ahrs3_t(:,2);
                yaw = yaw_mavlink_ahrs3_t(:,2);
                tahrs = datevec2Epoch(lng_mavlink_ahrs3_t(:,1));    %get time AHRS
                hzahrs = length(lat)/(tahrs(end)-tahrs(1));         %get sample rate
                
                % Rollrates data
                pitr = pitchspeed_mavlink_attitude_t(:,2);          %get gyroscope data
                rolr = rollspeed_mavlink_attitude_t(:,2);
                yawr = yawspeed_mavlink_attitude_t(:,2);
                trr = datevec2Epoch( pitchspeed_mavlink_attitude_t(:,1));
                hzrr = length(pitr)/(trr(end)-trr(1));              %get sample rate
                
                % Accelerometer data
                xac = xacc_mavlink_raw_imu_t(:,2);                  %get accelerometer data
                yac = yacc_mavlink_raw_imu_t(:,2);
                zac = zacc_mavlink_raw_imu_t(:,2);
                tac = datevec2Epoch( xacc_mavlink_raw_imu_t(:,1));
                hzac = length(xac)/(tac(end)-tac(1));               %get sample rate
                
                % Poisition and Velocity data
                x = x_mavlink_local_position_ned_t(:,2);
                y = y_mavlink_local_position_ned_t(:,2);
                z = z_mavlink_local_position_ned_t(:,2);
                vx = vx_mavlink_local_position_ned_t(:,2);
                vy = vy_mavlink_local_position_ned_t(:,2);
                vz = vz_mavlink_local_position_ned_t(:,2);
                tpo = datevec2Epoch( x_mavlink_local_position_ned_t(:,1));
                hzpo = length(x)/(tpo(end)-tpo(1));                 %get sample rate
                
                % interpolate to fixed time based on input hz
                t = linspace(trr(1),trr(end),hz*(trr(end)-trr(1)))';
                temp(:,1) = t;
                temp(:,2) = zeros(length(t),1);
                temp(:,3) = zeros(length(t),1);
                temp(:,4) = interp1(tahrs+randn(length(pit),1)*hz^-2,pit,t);
                temp(:,5) = interp1(tahrs+randn(length(pit),1)*hz^-2,rol,t);
                temp(:,6) = interp1(tahrs+randn(length(pit),1)*hz^-2,yaw,t);
                temp(:,7) = interp1(trr+randn(length(pitr),1)*hz^-2,pitr,t);
                temp(:,8) = interp1(trr+randn(length(pitr),1)*hz^-2,rolr,t);
                temp(:,9) = interp1(trr+randn(length(pitr),1)*hz^-2,yawr,t);
                temp(:,10) = interp1(tac+randn(length(xac),1)*hz^-2,xac,t);
                temp(:,11) = interp1(tac+randn(length(xac),1)*hz^-2,yac,t);
                temp(:,12) = interp1(tac+randn(length(xac),1)*hz^-2,zac,t);
                temp(:,13) = interp1(tahrs+randn(length(pit),1)*hz^-2,lat,t);
                temp(:,14) = interp1(tahrs+randn(length(pit),1)*hz^-2,lng,t);
                temp(:,15) = interp1(tahrs+randn(length(pit),1)*hz^-2,alt,t);
                temp(:,16) = interp1(tpo+randn(length(x),1)*hz^-2,x,t);
                temp(:,17) = interp1(tpo+randn(length(x),1)*hz^-2,y,t);
                temp(:,18) = interp1(tpo+randn(length(x),1)*hz^-2,z,t);
                temp(:,19) = interp1(tpo+randn(length(x),1)*hz^-2,vx,t);
                temp(:,20) = interp1(tpo+randn(length(x),1)*hz^-2,vy,t);
                temp(:,21) = interp1(tpo+randn(length(x),1)*hz^-2,vz,t);
                temp(:,22) = zeros(length(t),1);
                temp(:,23) = zeros(length(t),1);
                
                % store to one file
                testdata = [testdata ; temp];
            end
            
            save vp_data testdata
            clear
            
            % WIND DATA
        case 2  % Daughterboard data
            load vp_data.mat
            ss = size(testdata);
            fpath = [s0,'/',s1(2,:)]; % set path
            [d,numfiles,numdir] = getfpathinfo(fpath);
            temp = [];
            for i=1:numfiles
                name = d(i+numdir).name;
                t0 = str2double(name(9:end-4))-8*3600;
                fn = [fpath,'/',name];
                C = importdata(fn,',');
                t = C.data(:,1) + t0;
                wd = C.data(:,2);
                ws = C.data(:,3);
                temp = [temp;t,ws,wd];
            end
            testdata(:,2) = interp1(temp(:,1)+randn(length(temp(:,1)),1)*hz^-2,temp(:,2),testdata(:,1));
            testdata(:,3) = interp1(temp(:,1)+randn(length(temp(:,1)),1)*hz^-2,temp(:,3),testdata(:,1));
            
            save vp_data testdata
            clear
            
        case 3 % Ground truth data
            load vp_data.mat
            ss = size(testdata);
            fpath = [s0,'/',s1(3,:)]; % set path
            [d,numfiles,numdir] = getfpathinfo(fpath);
            temp = []; tempc = [];
            for i=1:numfiles
                name = d(i+numdir).name;
                fn = [fpath,'/',name];
                fid = fopen(fn);
                t = []; ws = []; wd = [];
                while true
                    C = fgetl(fid);
                    if length(C) == 56
                        %[Wed Aug 01 11:58:45.539 2018] $WIMWV,095,T,003.3,M,A*34
                        t = [t;C(10:11),'-',C(6:8),'-',C(26:29),'',C(12:24)];
                        ws = [ws;str2num(C(45:49))];
                        wd = [wd;str2num(C(39:41))];
                    elseif C == -1
                        break
                    end
                end
                tempc = [tempc;t];
                temp = [temp;ws,wd];
                fclose(fid);
            end
            tempc = UTC2epoch(tempc); 
            testdata(:,22) = interp1(tempc(:,1)+randn(length(temp(:,1)),1)*hz^-2,temp(:,1),testdata(:,1));
            testdata(:,23) = interp1(tempc(:,1)+randn(length(temp(:,1)),1)*hz^-2,temp(:,2),testdata(:,1));
           
            save vp_data testdata
            clear
    end
end

%% CUT TO INDIVIDUAL SETS


%% PLOT
% load vp_data.mat
% yyaxis left
% plot(testdata(:,1),testdata(:,2));
% yyaxis right
% plot(testdata(:,1),(testdata(:,19).^2 + testdata(:,20).^2).^0.5 );

%% FUNCTIONS

function [d,numfiles,numdir] = getfpathinfo(fpath)
% get num of files / dir
d = dir(fpath);
numfiles = sum(not([d.isdir]));
numdir = sum([d.isdir]);
end

function [tcor] = datevec2Epoch(t)
tcor = UTC2epoch(datestr(t));
end
