close all;

N=512;
delta_c = 31.250e3; % subcarrier_spacing in Hz
prefix_redundancy = 0.0655; % 6.55%

% random QPSK data symbols to modulate with OFDM
rng(2025);                                  % Set seed for reproducibility
M = 4;
dataSymbols = randi([0 M-1], 10000, 1);     % Generate 10000 random QPSK symbols (0, 1, 2, 3)
data = pskmod(dataSymbols, M, pi/M);        % QPSK modulation
scatterplot(awgn(data.',20))

OF = 3;
Lc = round(prefix_redundancy * N);

data = data.';
[x, u, w] = OFDMmod(data, N, Lc, OF);

Fs = OF * N * delta_c;       % frecuencia de muestreo tras oversampling y filtro

figure;
pwelch(x, 512, [], 512, Fs);

figure;
pwelch(x, 512, [], 512, Fs, 'centered')

%% With same X and Y axis
[Px, f] = pwelch(x, 512, [], 512, Fs, 'centered');
[Pu, f2] = pwelch(sqrt(OF)*u, 512, [], 512, Fs, 'centered');
figure;
plot(f, 10*log10(Px)); hold on;
plot(f2, 10*log10(Pu));
grid on;

xlabel('Frequency (Hz)');
ylabel('Power/frequency (dB/Hz)');
legend('PSD of x', 'PSD of sqrt(OF)*u');
title('PSD comparison on the same axis');

P = 150;
gtx = srrc(0, P, OF);
figure;
freqz(gtx, 1, 2048, Fs);
grid on;