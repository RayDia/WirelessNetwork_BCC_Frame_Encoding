%  f_LNG edited by ray 2017.5.10

clear all
% The multiplication by a factor of ¡Ì(13/6) is in order to normalize 
%the average power of the resulting OFDM symbol; 
%which utilizes 12 out of 52 subcarriers.
l = [1; 1; -1; -1; 1; 1; -1; 1; -1; 1; 1; 1; 1; 1; 1; -1; -1; 1; 1; -1; 1; -1; 1; 1; 1; 1; 0;
    1; -1; -1; 1; 1; -1; 1; -1; 1; -1; -1; -1; -1; -1; 1; 1; -1; -1; 1; -1; 1; -1; 1; 1; 1; 1];
ofdmS =[zeros(6, 1); l; zeros(5, 1)]; % T-L2
SmblT = ifft(ofdmS);
s_t = [SmblT(33:64); SmblT(:); SmblT(:)];
s_t(1) = s_t(1) / 2;
fs1 = reshape(s_t,4,40) ; % reshape the first symbol as in L-4
fs1 = fs1';
k = (0:39)' ; 
space = ones(1, 62); %73 - 16
space(find(space,1)) = ' ';
TableL6 = [num2str(k * 4,  '%3d|') num2str(fs1(:,1), '%6.3f') ...
            num2str(k * 4 + 1, '|%4d|') num2str(fs1(:,2), '%6.3f') ...
            num2str(k * 4 + 2,    '|%4d|') num2str(fs1(:,3), '%6.3f') ...
            num2str(k * 4 + 3, '|%4d|') num2str(fs1(:,4), '%6.3f') ];
temp = [num2str(160, '%3d|') num2str(SmblT(33, 1) / 2, '%6.3f') '+0' space];
TableL6 = [TableL6; temp];

