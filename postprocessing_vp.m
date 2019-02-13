%% Post Processing VP Data
% by Derek Hollenbeck

% Algorithm
% 1. load in data
% 2. load in marker data
% 3. find index close to marker
% 4. store flight in new data structure 'vpdata'

clc
clear

load vp_data.mat

% get marker data: col=1 start, col=2 stop
marker(1,:) = '13-Dec-2018 15:32:00';
marker(2,:) = '13-Dec-2018 15:37:00';
marker(3,:) = '13-Dec-2018 15:42:00';
marker(4,:) = '13-Dec-2018 15:48:00';
marker(5,:) = '13-Dec-2018 15:58:00';
marker(6,:) = '13-Dec-2018 16:04:00';

marker = UTC2epoch(marker);
marker = reshape(marker,[2,length(marker)/2]);

ss = size(marker);

for i=1:ss(2)
   vpdata(i).start = marker(1,i);
   vpdata(i).stop = marker(2,i);
   ind_start = find(testdata(:,1)<=vpdata(i).start,1,'last');
   ind_stop = find(testdata(:,1)<=vpdata(i).stop,1,'last');
   vpdata(i).data = testdata(ind_start:ind_stop,:);
end
%%
save vp_data_cut vpdata

%% Plot
testnum = 3;

yyaxis left
plot(vpdata(testnum).data(:,1),vpdata(testnum).data(:,4)*180/pi)
yyaxis right 
plot(vpdata(testnum).data(:,1),vpdata(testnum).data(:,5)*180/pi)