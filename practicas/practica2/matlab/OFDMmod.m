function [x, u, w] = OFDMmod(data, N, Lc, OF, nullpos)

% function [x, u, w] = OFDMmod(data, N, Lc, OF, nullpos)
%
% Simulates OFDM modulation
% Input: 
%  data    = row vector with (frequency-domain) data to be modulated
%  N       = IFFT size
%  Lc      = length of cyclic prefix, in samples
%  OF      = oversampling factor (sinc pulse shaping)
%  nullpos = vector with indices (within 1:N) of null subcarriers
% The data vector will be zero-padded if necessary in order to construct 
% an integer number of OFDM symbols.
% Output:
%  x = filtered   time domain samples ( OF*(N+Lc) samples per OFDM symbol )
%  u = unfiltered time domain samples ( OF*(N+Lc) samples per OFDM symbol )
%  w = time domain samples            (    (N+Lc) samples per OFDM symbol )

if nargin==4
    K = 0; 
    datapos = [1:N];
else
    K = length(nullpos);                % no. of null subcarriers
    datapos = setdiff([1:N], nullpos);  % indices of data subcarriers
end

Nu = N-K;   % No. of useful subcarriers

%% Format data for IFFT
    % hint: you may want to use 'reshape'
Nsymbols = ceil( length(data) / Nu );

% Zero-padding del vector de datos si es necesario
data_padded = [data, zeros(1, Nsymbols * Nu - data_len)];

data_blocks = reshape(data_padded, Nu, Nsymbols).';  % Reshape para organizar los datos en bloques de Nu símbolos (uno por símbolo OFDM)

data_IFFT = zeros(Nsymbols, N);
data_IFFT(:, datapos) = data_blocks;

%% N-point IFFT operation

out_IFFT = ifft(data_IFFT, N, 2);

%% Add Cyclic Prefix

CP = out_IFFT(:, end-Lc+1:end);

%% Parallel to serial
    % hint: you may want to use 'reshape'

%% Upsample
u = zeros(1,OF*length(w));
u(1:OF:end) = w;

P = 150;
gtx = srrc(0, P, OF);
x = filter(gtx,1,u);
data_IFFT = reshape(data_IFFT, Nu, []);  % Reshape for IFFT processing
w = ifft(data_IFFT, N, 2);  % Perform N-point IFFT along the second dimension
w = reshape(w, 1, []);  % Reshape back to a row vector
