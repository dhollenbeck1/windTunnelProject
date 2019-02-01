function [ sec ] = timestamp( YY,DD,HH,mm,SS )

s = datenum(HH,mm,SS); %second of the test

startofday = datetime(YY,08,DD,'Timezone','UTC'); %Time of start

timestamp = startofday + seconds(s) + hours(-7); % total time compensating for daylight saving time

sec = UTC2epoch(string(timestamp));

end
