close all; clear;

N=512;
delta_c = 31.250e3; % subcarrier_spacing in Hz
prefix_redundancy = 0.0655; % 6.55%
OF = 2;
Lc = round(prefix_redundancy * N);

% random QPSK data symbols to modulate with OFDM
rng(2025);                              % Set seed for reproducibility
M = 4;
dataSymbols = randi([0 M-1], 10000, 1); % Generate 10000 random QPSK symbols (0, 1, 2, 3)
txSig = pskmod(dataSymbols, M, pi/M); % QPSK modulation
scatterplot(awgn(txSig,20));
grid on;

data = txSig.';

Fs = OF * N * delta_c;
k_list = [0 5 20 40];% 60 80 100];

figure;
for i = 1:length(k_list)
    k = k_list(i);
    nullpos = [1:k, N-k+1:N]; % null in the edges

    [x, u, w] = OFDMmod(data, N, Lc, OF, nullpos);
    dem_data = OFDMdem(x, N, Lc, OF, ones(N,1), nullpos);

    subplot(2,2,i);
    %figure;
    scatter(real(dem_data), imag(dem_data));
    grid on;
    axis equal;
    title(sprintf('k = %d', k));
end
