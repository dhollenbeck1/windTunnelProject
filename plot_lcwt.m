clc
clear

load lcwt_data.mat

i = 4;
j = 4;
n = 1;
k = 1;
disp(['p= ',num2str(ref(i,j,n).p),', r= ',num2str(ref(i,j,n).r)])
plot(ref(i,j,n).data(:,k))

% figure
% hold on
% for i=1:4    
%     for j=1:1
%         plot(ref(i,j,1).data(:,1))
%     end
% end
% hold off