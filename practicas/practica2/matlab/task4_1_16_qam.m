close all; clear;

N=512;
nullpos = [];
delta_c = 31.250e3; % subcarrier_spacing in Hz
prefix_redundancy = 0.0655; % 6.55%
OF = 2;
Lc = round(prefix_redundancy * N);

% random QPSK data symbols to modulate with OFDM
rng(2025);                              % Set seed for reproducibility
M = 16;
dataSymbols = randi([0 M-1], 10000, 1); % Generate 10000 random 16 QAM
txSig = qammod(dataSymbols, M, 'gray'); % 16 QAM modulation
scatterplot(awgn(txSig,20));
hold on; grid on;

data = txSig.';

[x, u, w] = OFDMmod(data, N, Lc, OF, nullpos);

dem_data = OFDMdem(x, N, Lc, OF, ones(N,1), nullpos);

% gráfico de constelación
scatter(real(dem_data), imag(dem_data));
legend('Transmitted 16 QAM', 'Received 16 QAM', 'Location', 'best');
title('16-QAM Constellation: Transmitted vs Received');
xlabel('In-Phase');
ylabel('Quadrature');