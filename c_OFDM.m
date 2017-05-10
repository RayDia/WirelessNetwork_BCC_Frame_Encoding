%  c_OFDM.m
%            2011 Copyright Andrew P Paplinski, Monash University
%            13 Apr 2014 <= 6 Sept 2011
% This script maps  the coded DATA bits into OFDM symbols
%    16-QAM (Quadrature Amplitude Modulation) is used

clear all

% 16-QAM constelation, b0 b1 b2 b3
QAM16 = [-3-3i; -3-1i; -3+3i; -3+1i;  %  0  1  2  3
         -1-3i; -1-1i; -1+3i; -1+1i;  %  4  5  6  7
          3-3i;  3-1i;  3+3i;  3+1i;  %  8  9 10 11 
          1-3i;  1-1i;  1+3i;  1+1i]; % 12 13 14 15

load b_PPDU_D % PPDU_D  coded DATA as a 1x1152 binary vector  
n = numel(PPDU_D) ; % 1152
 
%  reshape DATA into a 4-row matrix, each column being a 16-QAM symbol
b4 = double(reshape(PPDU_D, 4, n/4)) ; 
% try  b4(:,1:10)
k = [8 4 2 1]*b4 ;  % a vector of indexes into QAM16
% try  k(1:10)

% frequency domain symbols 
freS = QAM16(k+1)/sqrt(10) ;  % n/4 = 1152/4 = 6*48 = 288

% reshape into 6 columns of symbols, each row represents one subcarrier.
eD = reshape(freS, 48, 6) ;  % is a 48x6 matrix of complex numbers

% Frequency domain representation of DATA symbols.  
% 48 data rows, 4 pilots, 0 at DC, 11 zeros = 64
%  6 zeros, 5 rows, p-21, 14 rows, p-7, 6 rows, 0, 6 rows, 
%                     p7, 13 rows, p21, 4 rows, 5 zeros
pilts = [1 1 1 -1 -1 -1 ] ;
ofdmS = [zeros(6,6) ; eD(1:5,:) ; pilts; eD(6:18,:) ;  % p-21
        pilts; eD(19:24,:); zeros(1,6); eD(25:30,:);  % p-7
        pilts; eD(31:43,:); -pilts; eD(44:48,:); zeros(5,6)]; %p7, p21

% ofdmS   is a 64x6 matrix of complex numbers. one coumn per symbol
    
%   Table L-20?requency domain of first DATA symbol

fs1 = reshape(ofdmS(:,1), 16,4) ; % reshape the first symbol as in L-20
k = (0:15)' ; 
TableL20 = [num2str(k-32,  '%3d|') num2str(fs1(:,1), '%6.3f') ...
            num2str(k-16, '|%4d|') num2str(fs1(:,2), '%6.3f') ...
            num2str(k,    '|%4d|') num2str(fs1(:,3), '%6.3f') ...
            num2str(k+16, '|%4d|') num2str(fs1(:,4), '%6.3f') ];

save c_ofdmS ofdmS

% Time domain representation of DATA symbols
%        Time guard needs to be added (to be done)

SmblT = ifft(ofdmS) ;  % inverse Fourier transform fix it!

msg_1stSmbl = real(SmblT(:,1)) ;
% a cyclic extension of the time signal, real part: see slide 18
%The time guard is formed by the cyclic extension of the time domain OFDM symbol s(1) ... s(64):
%? The resulting time vector has 81 time samples.
ss = SmblT(:, 1);
s_t = ([ss(49:64); ss; ss(1)]); % s(49) ... s(64)|s(1) ... s(64)|s(1)
s_t(1) = s_t(1) / 2;
s_t(80) = s_t(80) / 2;
% Produce Table L-25
fs1 = reshape(s_t(1:80), 4,20) ; % reshape the first symbol as in L-25
fs1 = fs1';
k = (0:19)' ; 
TableL25 = [num2str(400 + k * 4,  '%3d|') num2str(fs1(:,1), '%6.3f') ...
            num2str(400 + k * 4 + 1, '|%4d|') num2str(fs1(:,2), '%6.3f') ...
            num2str(400 + k * 4 + 2,    '|%4d|') num2str(fs1(:,3), '%6.3f') ...
            num2str(400 + k * 4 + 3, '|%4d|') num2str(fs1(:,4), '%6.3f') ];

%  Plotting the first symbol in time
dt = 3.2/64 ;  % microseconds
t = (0:63)*dt ;
plot(t, msg_1stSmbl), grid on
axis([0, 3.2, -0.2, 0.2])
title('The first OFDM symbol in the time domain')
xlabel('time \mus')

%msg_t = real(SymsT(:)) ;

