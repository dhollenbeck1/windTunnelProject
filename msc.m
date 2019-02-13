n = 100;
y = linspace(-180,180,n);

for k=1:n
    clc
    disp(['k= ',num2str(k)])
    u0 = [3.4,0,0];
    uf = []; vf = []; wf = [];
    rot = [];
    
    for i=1:lenr
        for j=1:lenp
            [vf,uf,wf] = rotateMeasurement(u0(2),u0(1),Pt(j),Rt(i),y(k));
            rot(i,j) = atan2d(vf,uf);
        end
    end
    
    [C,h] = contour(Xrt,Yrt,rot');
    clabel(C,h);
    shg;
end