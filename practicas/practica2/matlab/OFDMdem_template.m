function data = OFDMdem(r, N, Lc, OF, H, nullpos)

% function [data, H] = OFDMdem(r, N, Lc, OF, H, nullpos)
%
% Simulates OFDM modulation
% Input: 
%  r       = row vector with received signal samples 
%               ( OF*(N+Lc) samples/OFDM symbol )
%  N       = IFFT size
%  Lc      = length of cyclic prefix, in samples
%  OF      = oversampling factor
%  H       = column vector with frequency response of channel, to be used in FEQ
%  nullpos = vector with indices (within 1:N) of null subcarriers
% If the number of received samples (after taking into account the delays 
% of the pulse-shaping and matched filters) is not an integer multiple of 
% N+Lc, the last samples will be discarded. 
% Output:
%  data = row vector with demodulated data (data in null subcarriers is discarded)

if nargin==5
    K = 0; 
    datapos = [1:N];
else
    K = length(nullpos);                % no. of null subcarriers
    datapos = setdiff([1:N], nullpos);  % indices of data subcarriers
end

%% Filtering and downsampling
P = 150;
pulse = srrc(0, P, OF);
rxsig = filter(pulse,1,r);
% throw away initial samples due to filter delay
rxdec = rxsig(2*P*OF+1:OF:end); 

%% Format data for processing
    % Remember to discard last samples if symbol is incomplete


%% Discard cyclic prefix
       

%% N-point FFT


%% Frequency domain equalizer

%% Discard null subcarriers


%% Parallel to serial
    % hint: you may want to use 'reshape'

