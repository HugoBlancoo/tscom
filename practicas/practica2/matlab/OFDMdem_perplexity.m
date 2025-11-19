function data = OFDMdem_perplexity(r, N, Lc, OF, H, nullpos)

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
rxdec = rxsig(2*P*OF+1:OF:end);   % Decimación (resuelve el retardo y el sobremuestreo)

%% Format data for processing
% Calcular el número de símbolos OFDM recibidos completos:
Lsymb = N + Lc;
Nsymbols = floor(length(rxdec)/Lsymb);
rxdec = rxdec(1:Nsymbols * Lsymb);              % Descarta muestras incompletas
rxmat = reshape(rxdec, Lsymb, Nsymbols).';      % Un símbolo por fila

%% Discard cyclic prefix
rxmat_noCP = rxmat(:, Lc+1:end);                % Quita el prefijo cíclico de cada símbolo

%% N-point FFT (obtiene dominio de frecuencia)
Si_n = fft(rxmat_noCP, N, 2);                   % Analiza cada símbolo

%% Frequency domain equalizer (FEQ)
% Divide cada subportadora por la respuesta del canal, por símbolo:
Si_eq = Si_n ./ H.';                            % H es columna, transpón para broadcasting

%% Discard null subcarriers
Si_data = Si_eq(:,datapos);                     % Solo subportadoras útiles

%% Parallel to serial
% Recupera el vector original de datos en fila

data = reshape(Si_data.', 1, []);

end
