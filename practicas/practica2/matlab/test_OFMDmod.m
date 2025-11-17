N = 4;
data = [4, -1, 4, -1, 1, 4i, -1, 2i];
nullpos = [];
datapos = setdiff(1:N, nullpos);
Nu = N - length(nullpos);

Nsymbols = ceil( length(data) / Nu ); % 2

data_padded = [data, zeros(1, Nsymbols * Nu - length(data))];
data_blocks = reshape(data_padded, Nu, Nsymbols).'
data_IFFT = zeros(Nsymbols, N);
data_IFFT(:, datapos) = data_blocks % Matriz de entrada a la IFFT

out_IFFT = ifft(data_IFFT, N, 2)

Lc = 1;
CP = out_IFFT(:, end-Lc+1:end)

N = 6;
nullpos = [2, 5];
datapos = setdiff(1:N, nullpos);  % [1, 3, 4, 6]
Nu = N - length(nullpos);         % 4

data = [10, 11, 12, 13, 14, 15, 16, 15, 10 ,20];
Nsymbols = ceil(length(data) / Nu);  % 2

data_padded = [data, zeros(1, Nsymbols*Nu - length(data))];
data_blocks = reshape(data_padded, Nu, Nsymbols).'
data_IFFT = zeros(Nsymbols, N);
data_IFFT(:, datapos) = data_blocks

out_IFFT = ifft(data_IFFT, N, 2)

Lc = 1;
CP = out_IFFT(:, end-Lc+1:end)
wi_n = [CP, out_IFFT]

%% test OFMmod
N = 4;
Lc = 2;
OF = 1;
nullpos = [];
data = [4 -1 4 -1 1 4i -1 2i];

[x, u, w] = OFDMmod(data, N, Lc, OF, nullpos);
w
