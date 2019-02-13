%% Preprocessing script
% by Derek Hollenbeck
% updated: 2.1.19

% algorithm
%-----------------------------------
% Take in calibration data set first
% load in files one by one from control sensor then onboard sensor
% store in one matrix (as grided raw data)
% repeat for test data

% structure
%-----------------------------------
% ref = calibration  or reference data (no throttle)
% ref.name = directory name
% ref.size = size of matrix (2 x 2)
% ref.data = [ws_1, wd_1,ws_2,wd_2] (sampleSize x 2) 1&2 are control and
% onboard measurements
% ref.p    = pitch value
% ref.r    = roll value
% ref(P,R,S) = ref structure for each (Pitch,Roll,sensor) combination
% same structure applies to test.data (with throttle)

% sensors
%------------------------------------
% F1 - FT205 placed in wind tunel for LCWT experiment
% F3 - FT742 places on-board sUAS for LCWT experiment

% Clear data
clc
clear

% settings
ref = [];test = [];
day = 17;month = 7;year = 2018;
s0 = 'C:/Users/drkfr/Desktop/Wind/Data';        % top directory
s1 = ['TOf Data';'TOn Data'];
s2 = ['F1';'F3'];

% Add the paths
% addpath C:/Users/drkfr/Desktop/Wind/WindTestF1F3_Sum18/F1_Test0_NoThrottle/
% addpath C:/Users/drkfr/Desktop/Wind/WindTestF1F3_Sum18/F3_Test0_NoThrottle/
addpath(s0)

% test parameters
R = [0,10,20,30];
P = [30,20,10,0,-10,-20,-30];
sampleStart = 200;
sampleSize = 2400;

%% Reference data

tic
for sensor=1:2
    fpath = [s0,'/',s1(1,:),'/',s2(sensor,:)]; % set path
    [d,numfiles,numdir] = getfpathinfo(fpath);
    numfiles = 28;
    for run=1:numfiles
        
        clc
        % get file location and open it
        name = d(run+numdir,:).name;
        r = str2num(name(5:6));
        p = str2num(name(8:10));
        i = find(R==r);
        j = find(P==p);
        ref(i,j,sensor).name = name; ref(i,j,sensor).sensor = name(1:2);
        ref(i,j,sensor).p = p; ref(i,j,sensor).r = r;
        fn = [fpath,'/',name];
        fid = fopen(fn);
        
        disp('Processing: reference data')
        disp(['parsing: ',ref(i,j,sensor).name])
        disp(['param: p = ',num2str(p),', r = ',num2str(r)])
        disp(['index: i = ',num2str(i),', j = ',num2str(j)])
        % read line by line and check for errors
        % good read has length 53
        t = []; ws = []; wd = [];
        switch sensor
            case 1
                while true
                    C = fgetl(fid);
                    if length(C) == 53
        %[Wed Aug 01 11:58:46.617 2018] $WI,WVP=003.3,081,0*79
                        %                 t = [t;C(10:11),'-',C(6:8),'-',C(26:29),'',C(12:24)];
                        ws = [ws;str2num(C(40:44))];
                        wd = [wd;str2num(C(46:48))];
                    elseif C == -1
                        break
                    end
                end
            case 2
                while true
                    C = fgetl(fid);
                    if length(C) == 56
       %[Wed Aug 01 11:58:45.539 2018] $WIMWV,095,T,003.3,M,A*34
                        %                 t = [t;C(10:11),'-',C(6:8),'-',C(26:29),'',C(12:24)];
                        ws = [ws;str2num(C(45:49))];
                        wd = [wd;str2num(C(39:41))];
                    elseif C == -1
                        break
                    end
                end
        end
        % get sample
        %         t = t(sampleStart:sampleStart+sampleSize-1,:);
        %         t = UTC2epoch(t);
        ws = ws(sampleStart:sampleStart+sampleSize-1,:);
        wd = wd(sampleStart:sampleStart+sampleSize-1,:);
        
%         plot(ws)

        ref(i,j,sensor).data = [ws,wd];
        fclose(fid);
%         disp(['parsed: ',ref(i,j,sensor).name])
    end
end
%% Test Data

% test parameters
R = [0,5,10,15];
P = [15,10,5,0,-5,-10,-15];
sampleStart = 100;
sampleSize = 1500;

for sensor=1:2
    fpath = [s0,'/',s1(2,:),'/',s2(sensor,:)]; % set path
    [d,numfiles,numdir] = getfpathinfo(fpath);
    numfiles = 22;
    for run=1:numfiles
        clc
        % get file location and open it
        name = d(run+numdir,:).name;
        r = str2num(name(5:6)); p = str2num(name(8:10));
        i = find(R==r); j = find(P==p);
        test(i,j,sensor).name = name; test(i,j,sensor).sensor = name(1:2);
        test(i,j,sensor).p = p; test(i,j,sensor).r = r;
        fn = [fpath,'/',name];
        fid = fopen(fn);
        
        disp('Processing: test data')
        disp(['parsing: ',test(i,j,sensor).name])
        
        % read line by line and check for errors
        % good read has length 53
        t = []; ws = []; wd = [];
        switch sensor
            case 1
                while true
                    C = fgetl(fid);
                    if length(C) == 53
        %[Wed Aug 01 11:58:46.617 2018] $WI,WVP=003.3,081,0*79
                        %                 t = [t;C(10:11),'-',C(6:8),'-',C(26:29),'',C(12:24)];
                        ws = [ws;str2num(C(40:44))];
                        wd = [wd;str2num(C(46:48))];
                    elseif C == -1
                        break
                    end
                end
            case 2
                while true
                    C = fgetl(fid);
                    if length(C) == 56
       %[Wed Aug 01 11:58:45.539 2018] $WIMWV,095,T,003.3,M,A*34
                        %                 t = [t;C(10:11),'-',C(6:8),'-',C(26:29),'',C(12:24)];
                        ws = [ws;str2num(C(45:49))];
                        wd = [wd;str2num(C(39:41))];
                    elseif C == -1
                        break
                    end
                end
        end
        % get sample
        %         t = t(sampleStart:sampleStart+sampleSize-1,:);
        %         t = UTC2epoch(t);
        ws = ws(sampleStart:sampleStart+sampleSize-1,:);
        wd = wd(sampleStart:sampleStart+sampleSize-1,:);
        
        test(i,j,sensor).data = [ws,wd];
        fclose(fid);
%         disp(['parsed: ',ref(i,j,sensor).name])
    end
end

toc

save lcwt_data ref test

%% FUNCTIONS

function [d,numfiles,numdir] = getfpathinfo(fpath)
% get num of files / dir
d = dir(fpath);
numfiles = sum(not([d.isdir]));
numdir = sum([d.isdir]);
end