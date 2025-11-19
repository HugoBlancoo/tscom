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

% Define multipath channel htilde(t)
% h_tilde(t) = sum of Dirac deltas at specified delays
tau = [0, 2*T, 3*T, 4*T];              % Delays in seconds
alpha = [1, 0.7, 0.4, 0.5];            % Amplitudes
phi = [0, -pi/2, pi/4, pi/2];          % Phases

% Convert to complex channel taps
h_tilde = alpha .* exp(1j * phi);

% Convert delays to sample indices at rate Fs (Oversampled)
delay_samples_Fs = round(tau * Fs);

% Create discrete-time channel impulse response (High Res)
max_delay_Fs = max(delay_samples_Fs);
h_physical = zeros(1, max_delay_Fs + 1);
h_physical(delay_samples_Fs + 1) = h_tilde;
z = conv(x, h_physical);

% El receptor "inteligente" ve el canal a tasa de símbolo (1/T)
% Convertimos los retardos a muestras enteras de símbolo:
delay_samples_symbol = round(tau / T); % [0, 2, 3, 4]
% Creamos la respuesta impulsiva discreta a tasa de símbolo
h_eff = zeros(1, max(delay_samples_symbol) + 1);
h_eff(delay_samples_symbol + 1) = h_tilde;

% Compute correct H[k] for the equalizer
H = fft(h_eff, N).';

dem_data_correct = OFDMdem(z, N, Lc, OF, H, nullpos);

%% Plot received constellation WITH equalization
figure;
scatter(real(dem_data_correct), imag(dem_data_correct), 10, 'b', 'filled', 'MarkerFaceAlpha', 0.5);
grid on;
xlabel('In-Phase');
ylabel('Quadrature');
title('Received 16-QAM Constellation - With Perfect Equalization');
axis equal;