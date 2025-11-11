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

N = 6;
nullpos = [2, 5];
datapos = setdiff(1:N, nullpos);  % [1, 3, 4, 6]
Nu = N - length(nullpos);         % 4

data = [10, 11, 12, 13, 14, 15, 16, 17];
Nsymbols = ceil(length(data) / Nu);  % 2

data_padded = [data, zeros(1, Nsymbols*Nu - length(data))];
data_blocks = reshape(data_padded, Nu, Nsymbols).'
data_IFFT = zeros(Nsymbols, N);
data_IFFT(:, datapos) = data_blocks
