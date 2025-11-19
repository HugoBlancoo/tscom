N=512;
delta_c = 31.250e3; % subcarrier_spacing in Hz
prefix_redundancy = 0.0655; % 6.55%

% random QPSK data symbols to modulate with OFDM
rng(2025);                                  % Set seed for reproducibility
M = 4;
dataSymbols = randi([0 M-1], 10000, 1);     % Generate 10000 random QPSK symbols (0, 1, 2, 3)
data = pskmod(dataSymbols, M, pi/M);        % QPSK modulation

OF = 2;
Lc = round(prefix_redundancy * N);

data = data.';

k_list = [0, 10, 20, 30, 40, 50, 100];

for k = k_list
    figure;
    nullpos = [1:k, N-k+1:N];
    [x, u, w] = OFDMmod(data, N, Lc, OF, nullpos);
    
    Fs = OF * N * delta_c;
    [Px, f] = pwelch(x, 512, [], 512, Fs);
    plot(f, 10*log10(Px));
end