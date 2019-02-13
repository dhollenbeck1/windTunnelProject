function [u,v,w] = rotateMeasurement(um,vm,p,r,y)
% takes in measured velocities in u and v directions labeled: um, vm
% takes in pitch and roll angles: p and r
% outputs the u,v,w wind velocities
if nargin() == 4
   y = 0;
end

R1 = [[1,0,0];[0,cosd(p),sind(p)];[0,-sind(p),cosd(p)]];
R2 = [[cosd(r),0,sind(r)];[0,1,0];[-sind(r),0,cosd(r)]];
R3 = [[cosd(y),sind(y),0];[-sind(y),cosd(y),0];[0,0,1]];
R = R1*R2*R3;

for i=1:length(um)
    temp = [um(i),vm(i),0]*R;
    u(i) = temp(1);
    v(i) = temp(2);
    w(i) = temp(3);
end
end