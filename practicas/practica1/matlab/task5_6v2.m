clear; close all; clc;

% Parámetros
f0 = 3.3202e6;
fs = 100e6;
FS = 1;
gamma = 0.3;
Nbits = 11;
M = 16384;  % Aumentado para mayor resolución espectral
blocks = 15;
Nsamples = blocks * M;

% Generación de señal
n = (0:Nsamples-1).';
xt = (FS/2) * cos(2*pi*f0/fs * n);
xq = dquanti(xt, FS, Nbits, gamma);

% Procesamiento por bloques
xqblocks = reshape(xq, M, blocks);
X = fft(xqblocks, M);

% Promedio de potencia por bin
P_avg = mean(abs(X).^2, 2);

% Referencia para dBFS
k0 = round(f0 * M / fs);
n0 = (0:M-1).';
xref = FS * cos(2*pi*(k0/M) * n0);
Pref = max(abs(fft(xref, M)).^2);

% Medio-espectro (0..fs/2)
half = 1:(M/2);
freqs = (half-1) * (fs / M);
P_half = P_avg(half);

% Convertir a dBFS
P_dbfs = 10*log10(P_half / Pref);

% Plot - Espectro completo
figure('Name',sprintf('M=%d, γ=%.2f',M,gamma), 'Position', [100 100 1400 900]);

subplot(2,1,1);
plot(freqs/1e6, P_dbfs, 'LineWidth', 1.2);
title(sprintf('PSD completo - M=%d, N=%d, \\gamma=%.4g, Resolución: %.2f kHz', ...
      M, Nbits, gamma, fs/M/1e3));
xlabel('Frecuencia (MHz)');
ylabel('Potencia (dBFS)');
legend('PSD (avg)');
grid on;
xlim([0 fs/2/1e6]);

% Plot - Zoom hasta 9º armónico (aprox 30 MHz)
subplot(2,1,2);
plot(freqs/1e6, P_dbfs, 'LineWidth', 1.2);
title('Zoom región de armónicos (hasta ~30 MHz)');
xlabel('Frecuencia (MHz)');
ylabel('Potencia (dBFS)');
grid on;
xlim([0 30]);  % Mostrar hasta 30 MHz para ver los 9 armónicos
ylim([-120 0]);  % Limitar eje Y para mejor visualización