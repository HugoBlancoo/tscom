function data = OFDMdem(r, N, Lc, OF, H, nullpos)

if nargin==5
    datapos = (1:N);
else
    datapos = setdiff(1:N, nullpos);
end

%% === 1. Filtering and downsampling (matched filter) ===
P = 150;
pulse = srrc(0, P, OF);
rxsig = filter(pulse,1,r);

% Remove matched filter delay:
rxdec = rxsig(2*P*OF+1 : OF : end);   % take every OF-th sample

%% === 2. Format data: reshape into OFDM symbols (N+Lc samples each) ===
sym_len = N + Lc;
num_syms = floor(length(rxdec) / sym_len);

rxdec = rxdec(1 : num_syms * sym_len); % remove trailing incomplete part
rx_blocks = reshape(rxdec, sym_len, num_syms);  % (N+Lc)-by-num_syms

%% === 3. Remove cyclic prefix ===
rx_noCP = rx_blocks(Lc+1 : Lc+N, :);   % N-by-num_syms

%% === 4. N-point FFT ===
Y = fft(rx_noCP, N, 1);   % FFT column-wise (per OFDM symbol)

%% === 5. Frequency domain equalizer (Zero-Forcing) ===
H = H(:);   % ensure column vector
S_hat = Y ./ H;     % ZF equalization (channel known exactly)

%% === 6. Remove null subcarriers and serialize ===
data_blocks = S_hat(datapos, :);       % keep only data subcarriers
data = data_blocks(:).';               % P-to-S: return row vector

end
