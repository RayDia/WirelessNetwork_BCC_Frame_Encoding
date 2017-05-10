% d_SGNL.m
%            2013 Copyright Andrew P Paplinski, Monash University
%            20 Apr 2013 
% This script generates the SIGNAL field as in Appendix L.1.4 (see 18.3.4)

% Bits of the SIGNAL field as in Table L7
% 24 bits: Rate 4 bits; 0;  Length 12 bits;  Parity 1 bit; Tail 6 bits
%           36Mbs           100 bytes
sb = [1 0 1 1, 0, 0 0 1 0 0 1 1, zeros(1,12) ] ;

%1. the bits are encoded by the convolutional encoder with 1/2 rate (Table 1-8)
%2. interleaved to produced 48 bits as in Table L-9
%3. BPSK modulated
%4. pilots inserted  
% to produce the SIGNAL field in the frequency domain as in Table L11

%  write the code to  convert sb  into SGNLf

SGNLf = [zeros(1,6) 1 -1 -1  1 -1  1  1 -1 -1  1 ...
  1 -1  1 -1 -1 -1 -1 -1 -1  1 -1  1 -1  1 -1 -1 ...
  0  1 -1 -1 -1 -1 -1  1  1  1 -1 -1  1 -1 -1  1 ...
 -1 -1  1 -1 -1 -1  1 -1  1 -1 -1  zeros(1,5) ]' ;

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
