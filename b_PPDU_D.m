%  b_PPDU_D.m
%            2011 Copyright Andrew P Paplinski, Monash University
%            13 Apr 2014 <= ... 6 Sep 2011
% This script assembles the DATA field of the PPDU as in tables L13 to L19
% PPDU_D consists of 16-bit SERVICE field, 8*100-bit MPDU, 6-bit tail = 822
%       and padded with zeros to make the total number of bits to be 
%       a multiple of the OFDM symbols
%       For 36Mb/s mode, there are 36*4=144 data bits per OFDM symbol
%       the number of additional zero bits is nz = 144*ceil(822/144)-822=42
% Scrambling, convolutional coding, puncturing and interleaving is performed
% The number of coded bits per OFDM symbol will be 144*4/3 = 192

clear all

load a_MPDU  % MPDU
%The bits are prepended by the 16 SERVICE field bits and are appended by 6 tail bits. 
%The resulting 822 bits are appended by some number of bits with value 0 to yield an integral number of OFDM symbols. 
%For the 36 Mb/s mode, there are 144 data bits per OFDM symbol; 
%the overall number of bits is Ceiling (822/144) ¡Á 144 = 864. 
%Hence, 864 ? 822 = 42 zero bits are appended.

nd = numel(MPDU) + 16 + 6 ;     % 16 SERVICE field bits and 6 tail bits = 822 bits
nz = 144*ceil(nd/144)-nd ;  % number of additional bits to be appended 

% L.1.5.1 Delineating, SERVICE field prepending, and zero padding

dat = [zeros(1,16), MPDU, zeros(1,6+nz)];
% dat is presented in the Table L13 of the Annex
n = numel(dat) ;
c = 24; r = n/c ; spr = char(ones(r,1)*' ') ; % a column of spaces
tbl = char('0'+reshape(dat, c,r))' ;
TableL13 = [num2str(c*(0:r-1)', '%4d |') , ... 
            spr tbl(:,1:8) spr tbl(:,9:16) spr tbl(:,17:24)] ;
% spr tbl(:,8 : 1) spr tbl(:,16 : 9) spr tbl(:,24 : 17)] ;
%  L.1.5.2 Scrambling the BCC example
% scrambling the DATA bits
%  the scrambler seed = 1011101

datScr = zeros(1,n) ;
scr = uint8([1 0 1 1 1 0 1]) ; % the scrambler seed
s = zeros(n,1) ;
for k = 1:n  
    s(k) = xor(scr(1), scr(4)) ;
    datScr(k) = xor(dat(k), s(k)) ;
    scr = [scr(2:7) s(k)] ;
end

% Check datScr with Table L-15
% set zeros in locations 816:821 (see page 2549)
%After scrambling, the 6 bits in location 816 (i.e., bit 817) to 821 (i.e., bit 822) are set to 0. 
datScr(817:822) = 0 ;
%  check, for example, bits 216-239
%  datScr(217:240)
% printing datScr as in TableL15   
c = 24; r = n/c ; 
spr = char(ones(r,1) * ' ') ; % a column of spaces
tbl = char('0'+reshape(datScr, c,r))' ;
TableL15 = [num2str(c*(0:r-1)', '%4d |') , ... 
            spr tbl(:,1:8) spr tbl(:,9:16) spr tbl(:,17:24)] ;
% spr tbl(:,8 : 1) spr tbl(:,16 : 9) spr tbl(:,24 : 17)] ;

 
% L.1.6.1 Coding the DATA bits with convolutional encoder and rate 3/4
% convolutional encoder (2 1 3)
R = zeros(1,6) ;
datC = zeros(2,n) ;  % convoluted data as 2x864 binary matrix
for k = 1:n
    datC(1,k) = mod(sum([datScr(k) R([2 3 5 6])]),2); % 1st row
    datC(2,k) = mod(sum([datScr(k) R([1 2 3 6])]),2); % 2nd row
    R = [datScr(k) R(1:5)] ;
end
datCnv = datC(:) ; % Convoluted data as a 1728x1 binary vector

% Puncturing to get the code rate 3/4. see LN06, slides 28 -- 31
% puncture is 2/3  to get 1152 = 864 / 3 * 4
k1 = setdiff(1:n, 3:3:n);       % to be left in the 1st row
k2 = setdiff(1:n, 2:3:n);       % to be left in the 2nd row
datP = [datC(1,k1) ; datC(2,k2)] ;  % as a 2-row matrix
datCP = datP(:)' ;          % punctured DATA as 1x1152 binary vector
n = numel(datCP) ;          % total number of elements after puncturing

% printing datCP as in TableL16   
c = 32; 
r = n/c ; 
spr = char(ones(r,1)*' ') ; % a column of spaces
tbl = char('0'+reshape(datCP, c,r))' ;
TableL16 = [num2str(32*(0:r-1)', '%4d |') , ... 
    spr tbl(:,1:8) spr tbl(:,9:16) spr tbl(:,17:24) spr tbl(:,25:32)] ;
% spr tbl(:,8 : 1) spr tbl(:,16 : 9) spr tbl(:,24 : 17) spr tbl(:, 32:25] ;
%why 144? 36Mb/s
%    144 bits per OFDM symbol are incresed by 4/3 to become 192
nps = 144*4/3;  %  = 192
ns = n/nps ;    % number of OFDM symbols = 6

% reshaping datCP into one OFDM symbol per column
bsmbl = reshape(datCP, nps,ns) ;  % 192x6 binary matrix

%  L.1.6.2 Interleaving the DATA bits
DSprm = zeros(nps, ns) ; % permuted data symbols

k = 0:nps-1 ;
for sn = 1:ns   % the symbol loop
   %  The first permutation
   ii = (nps/16)*mod(k,16) + floor(k/16) ;  % compare with Table L-17
   DS(ii+1) = bsmbl(:,sn) ;  % the symbol after the first permutation

   % the second permutation
   s = 2 ;  % Nbpsc/2
   jj = s*floor(k/s) + mod(k + nps - floor(16*k/nps), s) ; % Table L-18
   DSprm(jj+1,sn) = DS ; % after 2nd permutation. One symbol per column
end

% The first DATA symbol after interleaving DSperm(:,1) is in Table L-19
TableL19 = [num2str((0:31)', '%2d: :') reshape(dec2bin(DSprm(:,1)),32,6)] ;

PPDU_D = DSprm(:)' ; % Doubly interleaved DATA as a 1x1152 binary vector

save b_PPDU_D PPDU_D

