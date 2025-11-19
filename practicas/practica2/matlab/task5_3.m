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
txSig = pskmod(dataSymbols, M, pi/M); % 16 QAM modulation
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

% Convert delays to sample indices at rate Fs
delay_samples = round(tau * Fs);

% Create discrete-time channel impulse response
max_delay = max(delay_samples);
h_tilde_discrete = zeros(1, max_delay + 1);
for i = 1:length(tau)
    h_tilde_discrete(delay_samples(i) + 1) = h_tilde(i);
end

z = conv(x, h_tilde_discrete);

dem_data = OFDMdem(z, N, Lc, OF, ones(N, 1), nullpos);

%% Plot received constellation without equalization
figure;
scatter(real(dem_data), imag(dem_data), 10, 'b', 'filled', 'MarkerFaceAlpha', 0.5);
grid on;
xlabel('In-Phase');
ylabel('Quadrature');
title('Received 16-QAM Constellation - No Equalization (H=1)');
axis equal;

%% For comparison: plot ideal 16-QAM constellation
hold on;
ideal_qam = qammod(0:15, 16);
scatter(real(ideal_qam), imag(ideal_qam), 100, 'r', 'x', 'LineWidth', 2);
legend('Received (no EQ)', 'Ideal 16-QAM', 'Location', 'best');