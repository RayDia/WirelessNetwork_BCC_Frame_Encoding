% a_MPDU.m edited by ray 2017.5.9 
% fcs function is also added 
% origin by
%            2011 Copyright Andrew P Paplinski, Monash University
%            13 Apr 2014 <= ... 13 Aug 2012  
% This script assembles the MPDU as in Annex L1,  
%        Table L1 - The message for the BCC example
% The MPDU consists of the:
%    24-byte  header (hdr)
%    72-byte  data/msg
%     4-byte  CRC/FCS  calculated in this script.
    
clear all

msg1='Joy, bright spark of divinity, Daughter of Elysium, Fire-insired we trea';
%why do this?
msg = msg1;
msg([31 52]) = char(hex2dec('0a')) ; % newline characters inserted where required 

% header - 24 bytes as in Table L-1
% Frame Control(2bytes)=DATA frame,fromDS, Duration(2bytes) = 46us,  
%    3 addresses= 3*6=18, SC(2bytes)  see 8.3.2.1 Data frame format a_dataL1
hdrX='04 02 00 2e 00 60 08 cd 37 a6 00 20 d6 01 3c f1 00 60 08 ad 3b af 00 00';

%  The header and the message as 96x1 vector of decimal (8-bit) numbers
hdrmsg_d = [sscanf(hdrX,'%x') ; uint8(msg)'] ; % 96x1 vector 
%  The header and the message in a binary form, one byte per row, as text
Db = dec2bin(hdrmsg_d, 8) ; % 96x8=768=k  
% A binary vector, least significant bite first:
k = numel(Db) ;
D = reshape(fliplr(Db)', 1, k) > '0';  % data in binary form as logical
% physical data store
% Calculate FCS as in Clause 8.2.4.8 FCS field
Gh = '04C11DB7'; % CRC polynomial. The most significant 1 implied
%       fcs  - my frame check sequence function
R = 1 - fcs(Gh, D) ; % final complement in the transmitter

% converting into a hex form for testing
Rhx = dec2hex(bin2dec(flipud(reshape(dec2bin(R), 8,4))')) ;  % 67 33 21 B6 

MPDU = [D R] ;  % MAC Protocol Data Unit as 1x800 binary vector
save a_MPDU MPDU
%figure(1)
%plot(MPDU);

% Visualization 
% Table L-1       given MPDU

% one column of bytes in hex as text
duH = dec2hex(bin2dec(fliplr(reshape(dec2bin(MPDU'), 8,100)'))) ;
%figure(2)
%plot(hex2dec(duH));
tb =  reshape(duH', 10,20)' ;  %  MPDU as 20 rows, 5 cols
spc = char(32*ones(20,1)) ;    % a column of spaces 

TableL1 = [num2str((1:5:100)', '%2d:') spc tb(:,1:2) spc tb(:,3:4) spc ... 
                             tb(:,5:6) spc tb(:,7:8) spc tb(:,9:10) ]; 
% testing FCS in the receiver
                               % 
RR = fcs(Gh, MPDU) ; 
RRhx = dec2hex(bin2dec(reshape(dec2bin(RR), 8,4)')) ; % C7 04 DD 7B
