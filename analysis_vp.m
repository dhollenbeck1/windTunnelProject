clc
clear

load vp_data.mat

t = testdata(:,1);

xn = testdata(:,16);
xe = testdata(:,17);

vn = testdata(:,19);
ve = testdata(:,19);

ws = testdata(:,2);
wd = testdata(:,3);

u = ws.*sind(wd);
v = ws.*cosd(wd);

uc = vn - u;
vc = ve - v;

plot(t,vn,t,ve)