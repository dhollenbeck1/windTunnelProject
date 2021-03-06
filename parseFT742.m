function [time,wind_speed,wind_dir] = parseFT742(fn,day,month,year,timezoneshift)
format long g
temp = importdata(fn," ");
dat = char(string(temp));
hhmmss = dat(:,13:24);
dv = datevec(hhmmss,'HH:MM:SS.FFF');
ss = dv(:,4)*3600 + dv(:,5)*60 + dv(:,6);
sod = datetime(year,month,day,'Timezone','UTC');
ts = sod + seconds(ss) + hours(timezoneshift);
t = UTC2epoch(string(ts));
wind_speed = str2num(dat(:,45:49));
wind_dir = str2num(dat(:,39:41));

% fix time
k = find(diff(t)==1)+1;
pos = 2; ind = k(pos);
time = t(ind:end);
wind_speed = wind_speed(ind:end);
wind_dir = wind_dir(ind:end);
count = 1;
j = 0;

for i=1:length(time)
    if i == k(pos+count)-ind+1 && pos+count < length(k)
        j = 0; count = count + 1;
        time(i) = time(i) + (mod(j,10))*0.1;
    else
        time(i) = time(i) + (mod(j,10))*0.1;
    end
    j = j + 1;
end
end