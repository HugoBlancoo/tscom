close all; clear;

N=64;
T = 0.25e-6;
nullpos = [29, 30, 31, 32, 33, 34] + 1; %matlab indexa desde 1
prefix_redundancy = 0.09375; % 9.375%
Lc = round(prefix_redundancy * N);

OF = 10;
Fs = OF / T;

% random QPSK data symbols to modulate with OFDM
rng(2025);                              % Set seed for reproducibility
M = 16;
dataSymbols = randi([0 M-1], 10000, 1); % Generate 10000 random 16 QAM symbols
txSig = pskmod(dataSymbols, M, pi/M); % 16 QAM modulation
scatterplot(awgn(txSig,20));
hold on; grid on;

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

% Generate transmit and receive filters
P = 150;
gtx = srrc(0, P, OF);            % Transmit filter
grx = srrc(0, P, OF);            % Receive (matched) filter

%% Compute equivalent channel h(t) = gtx * h_tilde * grx
h_aux = conv(gtx, h_tilde_discrete);
heq = conv(h_aux, grx);

% Compute the FFT Heq = fft(heq,8192)
Nfft = 8192;
Heq = fft(heq,8192);

% Plot Heq magnitude
figure;
plot(linspace(-20, 20, 8192), 20*log10(abs(fftshift(Heq))));
grid on;
xlabel('Frequency (MHz)');
ylabel('Magnitude (dB)');
title('Equivalent Channel Frequency Response');
xlim([-20 20]);

%% Zoom in on the OFDM signal bandwidth
% Calculate OFDM bandwidth
delta_c = 1 / (N * T);           % Subcarrier spacing
BW_ofdm = N * delta_c / 1e6;     % OFDM bandwidth in MHz

fprintf('Subcarrier spacing: %.3f kHz\n', delta_c/1e3);
fprintf('OFDM bandwidth: %.3f MHz\n', BW_ofdm);

figure;
plot(linspace(-20, 20, 8192), 20*log10(abs(fftshift(Heq))), 'LineWidth', 1.5);
grid on;
xlabel('Frequency (MHz)');
ylabel('Magnitude (dB)');
title('Channel Response - OFDM Passband');
xlim([-BW_ofdm/2, BW_ofdm/2]);
ylim([min(20*log10(abs(fftshift(Heq))))-5, max(20*log10(abs(fftshift(Heq))))+5]);

%% largest difference (in dB) between passband points of the channel transfer function's magnitude
% Frequency axis in MHz
freq_axis = linspace(-Fs/2, Fs/2, Nfft) / 1e6;

% Analyze flatness within passband
idx_passband = find(abs(freq_axis) <= BW_ofdm/2);
Heq_passband_dB = 20*log10(abs(fftshift(Heq)));
Heq_passband_dB = Heq_passband_dB(idx_passband);

% Passband Analysis
max_dB = max(Heq_passband_dB);
min_dB = min(Heq_passband_dB);
diff_dB = max_dB - min_dB;
fprintf('Maximum magnitude: %.2f dB\n', max_dB);
fprintf('Minimum magnitude: %.2f dB\n', min_dB);
fprintf('Peak-to-peak variation: %.2f dB\n', diff_dB);