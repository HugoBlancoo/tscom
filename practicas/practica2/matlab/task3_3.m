clear; close all;

N=512;
delta_c = 31.250e3; % subcarrier_spacing in Hz
prefix_redundancy = 0.0655; % 6.55%

% random QPSK data symbols to modulate with OFDM
rng(2025);                                  % Set seed for reproducibility
M = 4;
dataSymbols = randi([0 M-1], 10000, 1);     % Generate 10000 random QPSK symbols (0, 1, 2, 3)
txSig = pskmod(dataSymbols, M, pi/M);        % QPSK modulation
OF = 2;
Lc = round(prefix_redundancy * N);
data = txSig.';

Fs = OF * N * delta_c;
%k_list = [0, 10, 20, 30, 40, 50, 100, 150, 200, 225, 230, 240, 250];
k_list = [235:240 245:250];

for k = k_list
    nullpos = [1:k, N-k+1:N]; % null in the edges
    [x, u, w] = OFDMmod(data, N, Lc, OF, nullpos);

    [Px, f] = pwelch(x, 512, [], 512, Fs, 'centered');
    % figure;
    % plot(f, 10*log10(Px));
    % xlabel('Frequency (Hz)');
    % ylabel('Power/frequency (dB/Hz)');

    psd_peak = max(10*log10(Px));
    idx_p7 = find(f>=7e6,1);
    idx_m7 = find(f<=-7e6,1,'last');
    psd_at_p7 = 10*log10(Px(idx_p7));
    psd_at_m7 = 10*log10(Px(idx_m7));
    att_p7 = psd_peak - psd_at_p7;
    att_m7 = psd_peak - psd_at_m7;
    fprintf('k = %d, Attenuation at +7MHz = %6.2f(dB/Hz), at -7MHz = %6.2f(dB/Hz), min = %6.2f\n',k,att_p7,att_m7,min(att_m7,att_p7));
end