%  e_SHRT edited by ray 2017.5.10

clear all
% The multiplication by a factor of ¡Ì(13/6) is in order to normalize 
%the average power of the resulting OFDM symbol, 
%which utilizes 12 out of 52 subcarriers.
seq = sqrt(13/6)*[0; 0; 1+1i; 0; 0; 0; -1-1i; 
    0; 0; 0; 1+1i; 0; 0; 0; -1-1i; 0; 0; 0; -1-1i; 
    0; 0; 0; 1+1i; 0; 0; 0; 0; 0; 0; 0; -1-1i; 
    0; 0; 0; -1-1i; 0; 0; 0; 1+1i; 0; 0; 0; 
    1+1i; 0; 0; 0; 1+1i; 0; 0; 0; 1+1i; 0;0];
ofdmS =[zeros(6, 1); seq; zeros(5, 1)]; % T-L2
SmblT = ifft(ofdmS);
s_t = [SmblT(:); SmblT(:); SmblT(1:32)];
s_t(1) = s_t(1) / 2;
fs1 = reshape(s_t, 4, 40) ; % reshape the first symbol as in L-4
fs1 = fs1';
k = (0:39)' ; 
space = ones(1, 57); %73 - 16
space(find(space, 1)) = ' ';
TableL4 = [num2str(k * 4,  '%3d|') num2str(fs1(:,1), '%6.3f') ...
            num2str(k * 4 + 1, '|%4d|') num2str(fs1(:,2), '%6.3f') ...
            num2str(k * 4 + 2,    '|%4d|') num2str(fs1(:,3), '%6.3f') ...
            num2str(k * 4 + 3, '|%4d|') num2str(fs1(:,4), '%6.3f') ];
temp = [num2str(160, '%3d|') num2str(SmblT(33, 1) / 2, '%6.3f') space];
TableL4 = [TableL4; temp];

