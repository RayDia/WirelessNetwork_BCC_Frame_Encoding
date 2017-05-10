% d_SGNL.m edited by ray 2017.5.9
% origin           2013 Copyright Andrew P Paplinski, Monash University
%            20 Apr 2013 
% This script generates the SIGNAL field as in Appendix L.1.4 (see 18.3.4)

% Bits of the SIGNAL field as in Table L7
% 24 bits: Rate 4 bits; 0;  Length 12 bits;  Parity 1 bit; Tail 6 bits
%           36Mbs           100 bytes
sb = [1 0 1 1, 0, 0 0 1 0 0 1 1, zeros(1,12) ] ; %L.1.4.1 SIGNAL field bit assignment

%1. the bits are encoded by the convolutional encoder with 1/2 rate (Table 1-8)
% convolutional encoder (2 1 3)
n = max(size(sb));
R = zeros(1,6) ;
sb_C = zeros(2,n) ;  % convoluted data as 2x24 binary matrix
for k = 1:n
    sb_C(1,k) = mod(sum([sb(k) R([2 3 5 6])]),2); % 1st row
    sb_C(2,k) = mod(sum([sb(k) R([1 2 3 6])]),2); % 2nd row
    R = [sb(k) R(1:5)] ;
end
%Table L-8?SIGNAL field bits after encoding
sb_Cnv = sb_C(:) ; % Convoluted data as a 48x1 binary vector
%2. interleaved to produced 48 bits as in Table L-9
%  L.1.6.2 Interleaving the DATA bits
%All encoded data bits shall be interleaved by a block interleaver 
%with a block size corresponding to the number of bits in a single OFDM symbol, NCBPS. 
sb_nps = 48;  %  = 8
sb_ns = 1;    % number of OFDM symbols = 6

% reshaping datCP into one OFDM symbol per column
sb_bsmbl = reshape(sb_Cnv, sb_nps,sb_ns) ;  % 48 * 1 binary matrix

%  L.1.6.2 Interleaving the DATA bits
sb_DSprm = zeros(sb_nps, sb_ns) ; % permuted data symbols

k = 0:sb_nps-1 ;
for sn = 1:sb_ns   % the symbol loop
   %The first permutation is defined by the rule
   %i = s ¡Á Floor(j/s) + (j + Floor(16 ¡Á j/NCBPS)) mod s j = 0,1,... NCBPS ? 1
   %s = max(sb_nps / 2, 1);
   %ii = s * floor( j / s) + mod( (j + floor(16 * j / sb_nps)), s);
   ii = (sb_nps/16)*mod(k,16) + floor(k/16) ;  % compare with Table L-17
   sb_DS(ii+1) = sb_bsmbl(:,sn) ;  % the symbol after the first permutation

   %s = max(sb_nps / 2, 1) ;  % Nbpsc/2
   % The second permutation is defined by the rule 
   % k = 16 ¡Á i ? (NCBPS ? 1)Floor(16 ¡Á i/NCBPS) i = 0,1,... NCBPS ? 1
   s = 1; % ??
   %s = max(sb_nps / 2, 1);
   jj = s*floor(k/s) + mod(k + sb_nps - floor(16*k/sb_nps), s); % Table L-18
   %kk = 16 * ii - (sb_nps - 1) * floor(16 * ii / sb_nps);
   sb_DSprm(jj+1,sn) = sb_DS ; % after 2nd permutation. One symbol per column
end

%disp(sb_DSprm');
%3. BPSK modulated
sb_DSprm = sb_DSprm + 1;
sb_DSprm(find(sb_DSprm == 1)) = -1;
sb_DSprm(find(sb_DSprm == 2)) = 1;
%disp(sb_DSprm');
sb_DSprm = sb_DSprm';
%4. pilots inserted 
sb_d = [sb_DSprm(1:5) 1 sb_DSprm(6:48)];
sb_d1 = [sb_d(1:19) 1 sb_d(20:49)];
sb_d = [sb_d1(1:26) 0 sb_d1(27:50)];
sb_d1 =[sb_d(1:33) 1 sb_d(34:51)];
sb_d = [sb_d1(1:47) -1 sb_d1(48 : 52)];
sb_DSprm = sb_d;
sb_DSprm = [zeros(1, 6) sb_DSprm zeros(1, 5)]';
sb = sb_DSprm;
sb_ofdmS = sb;
% to produce the SIGNAL field in the frequency domain as in Table L11
fs1 = reshape(sb_ofdmS(:,1), 16,4) ; % reshape the first symbol as in L-11
fstemp = zeros(16, 1);
for i = 1 : 16
    symbol1(i, 1) = '+';
    symbol2(i, 1) = 'i';
end
k = (0:15)' ; 
TableL11 = [num2str(k-32,  '%3d|') num2str(fs1(:,1), '%6.3f') symbol1 num2str(fstemp, '%6.3f') symbol2...
            num2str(k-16, '|%4d|') num2str(fs1(:,2), '%6.3f') symbol1 num2str(fstemp, '%6.3f') symbol2 ...
            num2str(k,    '|%4d|') num2str(fs1(:,3), '%6.3f') symbol1 num2str(fstemp, '%6.3f') symbol2 ...
            num2str(k+16, '|%4d|') num2str(fs1(:,4), '%6.3f') symbol1 num2str(fstemp, '%6.3f') symbol2];

%  write the code to  convert sb  into SGNLf
SGNLf = sb;
%SGNLf = [zeros(1,6) 1 -1 -1  1 -1  1  1 -1 -1  1 ...
%  1 -1  1 -1 -1 -1 -1 -1 -1  1 -1  1 -1  1 -1 -1 ...
%  0  1 -1 -1 -1 -1 -1  1  1  1 -1 -1  1 -1 -1  1 ...
% -1 -1  1 -1 -1 -1  1 -1  1 -1 -1  zeros(1,5) ]' ;

k = [33:64 1:32]' ; % re-order the bits for the IFFT as in Figure 18-3
%         perform ifft and conjugate to fix the sign of the imaginary part
SGt = conj(ifft(SGNLf(k))) ; 

% circular extention (time guard interval)
SGNLt = [SGt(end-15:end) ; SGt ; SGt(1)] ; 
% windowing
SGNLt([1,end]) = SGNLt([1,end])/2 ; % complete SIGNAL in the time domain
n = numel(SGNLt) ; % = 81

% visualization - Table L12 Time domain representation of the SIGNAL field
sg = reshape([SGNLt; 0; 0; 0], 4, (n+3)/4)' ;
TableL12 = num2str(sg, '%8.3f')  ;

save d_SGNL SGNLt
