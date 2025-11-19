close all; clear;

N=64;
T = 0.25e-6;
nullpos = [29, 30, 31, 32, 33, 34] + 1; %matlab indexa desde 1
prefix_redundancy = 0.09375; % 9.375%
Lc = round(prefix_redundancy * N);

OF = 10; % sampling rate of 10/T Hz
Fs = OF / T;

% random QPSK data symbols to modulate with OFDM
rng(2025);                              % Set seed for reproducibility
M = 16;
dataSymbols = randi([0 M-1], 10000, 1); % Generate 10000 random 16 QAM symbols
txSig = qammod(dataSymbols, M, 'UnitAveragePower', true); % 16 QAM modulation
%scatterplot(awgn(txSig,20));hold on; grid on;
data = txSig.';

[x, u, w] = OFDMmod(data, N, Lc, OF, nullpos);

%% \tilde h(t) = \delta(t) -0.8\delta(t-5T) +0.7\delta(t-10T).
tau_symbol_rate = [0, 5, 10]; % Porque son 0, 5T, 10T
alpha = [1, -0.8, 0.7];

% Creamos el canal equivalente h[n] (a tasa de símbolo) para H
h_eff = zeros(1, 11); % Longitud máxima es 10, +1 por índice 1 de Matlab
h_eff(tau_symbol_rate + 1) = alpha;

% Ahora calculamos la H correcta para el ecualizador (tamaño N=64)
H = fft(h_eff, N).'; 

% Canal físico para la transmisión (oversampled) para generar z
delay_samples_Fs = tau_symbol_rate * OF;
h_physical = zeros(1, max(delay_samples_Fs) + 1);
h_physical(delay_samples_Fs + 1) = alpha;

% Received signal
z = conv(x, h_physical);

% Demodulate with equalization
dem_data = OFDMdem(z, N, Lc, OF, H, nullpos);

%% Plot constellation
figure;
scatter(real(dem_data), imag(dem_data), 10, 'b', 'filled', 'MarkerFaceAlpha', 0.5);
grid on;
xlabel('In-Phase');
ylabel('Quadrature');
title('Received 16-QAM Constellation - Simplified Channel');
axis equal;

% Ideal constellation for reference
hold on;
ideal_qam = qammod(0:15, 16, 'UnitAveragePower', true);
scatter(real(ideal_qam), imag(ideal_qam), 100, 'r', 'x', 'LineWidth', 2);
legend('Received (with EQ)', 'Ideal 16-QAM', 'Location', 'best');