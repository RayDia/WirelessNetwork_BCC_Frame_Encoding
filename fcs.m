% function fcs
function rem = fcs(gh, msg)
%msg_h = dec2hex(msg);
%msg_h = msg_h(:);

%msg_b = dec2bin(msg);
%msg_b = msg_b(:);

%msg_bn = uint8(msg_b - '0');

%cal
bits = uint8(msg);
%crc 
temp = de2bi((hex2dec(gh)), 32);
temp = temp(max(size(temp)) : -1 : 1);
%poly = [1 de2bi(hex2dec('EDB88320'), 32)]'; % already change
poly = [1 temp]';

bits = bits(:);

bits(1:32) = 1 - bits(1:32);% flip first 32 bits
bits = [bits; zeros(32,1)];

rem = zeros(32,1);%remainder to 0
for i = 1:length(bits)
    rem = [rem; bits(i)]; 
    if rem(1) == 1
        rem = bitxor(uint8(rem), uint8(poly)); % mod(rem + poly, 2)
    end
    rem = rem(2:33);
end

rem = rem';

%ret = 1 - rem;% flip the remainder
%ret = ret';