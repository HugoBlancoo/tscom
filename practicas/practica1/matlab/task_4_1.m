f0 = 37.1094e6;
M = 1024;
fs = 100e6;
Nbits = 12;
blocks = 15;
FS = 1;

Nsamples = blocks * M;

%% Generar FS sinusoidal
n = 0:Nsamples-1; % Create a time vector for the samples
xt = FS * cos(2*n*pi*f0/fs);
xq = quanti(xt, FS, Nbits);

xqblocks = reshape(xq, M, 15);

X = fft(xqblocks, M);

%% Average the squared magnitude of the DFT coefficients over the 15 blocks and plot the results
%between 0 and fs/2, in dBFS
P_avg = mean(abs(X).^2, 2);

norm_const = (M / 2)^2;
P_dbfs = 10 * log10(P_avg / norm_const);

f_axis = (0:M-1) * fs / M; % Eje de frecuencia de 0 a fs
plot(f_axis(1:M/2 + 1) / 1e6, P_dbfs(1:M/2 + 1));
grid on;
xlabel('Frequency (MHz)');
ylabel('Power (dBFS)');
title('Espectro de Potencia Promedio (N=12 bits, M=1024)');
ylim([-140, 10]); % Ajusta el límite Y para ver mejor el piso de ruido