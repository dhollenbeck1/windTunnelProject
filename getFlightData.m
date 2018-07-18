function [t_fd,lat,lon] = getFlightData(fn,year,month,day)
% This function takes in:
%   filename
%   year, month, and day (beginning of the week in question).
% Returns the lat, lon, and local time in second from Jan 1, 1970

load(fn)                            % Load the flight data
sod = GPS(:,4)/1000;                % GPS seconds of the week
startofday = datetime(year,...
    month,day,'Timezone','UTC');    % Time to start of week
timestamp = startofday + ...
    seconds(sod) + hours(-7);       % Local time in datetime type
t_fd = UTC2epoch(string(timestamp));% Convert to epoch
lat = GPS(:,8);
lon = GPS(:,9);
end