function [u,v,w] = rotateMeasurement(um,vm,p,r)
% takes in measured velocities in u and v directions labeled: um, vm
% takes in pitch and roll angles: p and r
% outputs the u,v,w wind velocities
u = zeros(length(um),1); 
v = u;
w = u;

R1 = [[1,0,0];[0,cosd(p),-sind(p)];[0,sind(p),cosd(p)]];
R2 = [[cosd(r),0,sind(r)];[0,1,0];[-sind(r),0,cosd(r)]];
R = R1*R2;

for i=1:length(um)
    temp = [um(i),vm(i),0]*R;
    u(i) = temp(1);
    v(i) = temp(2);
    w(i) = temp(3);
end
end