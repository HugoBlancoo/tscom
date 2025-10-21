clear; close all; clc;

f0 = 3.3202e6;
fs = 100e6;
FS = 1;
gamma = 0.3;
Nbits = 11;
M = 2048;
blocks = 15;

Nsamples = blocks * M;
n = (0:Nsamples-1).';
xt = (FS/2) * cos(2*pi*f0/fs * n);

xq = dquanti(xt, FS, Nbits, gamma);
xqblocks = reshape(xq, M, blocks);

X = fft(xqblocks, M);

% Promedio de potencia por bin (power)
P_avg = mean(abs(X).^2, 2);

% Referencia para dBFS: potencia máxima de un coseno full-scale alineado con bin k0
k0 = round(f0 * M / fs);      % bin aproximado de f0
% referencia: bloquear una señal exactamente en el bin k0 (un bloque)
n0 = (0:M-1).';
xref = FS * cos(2*pi*(k0/M) * n0);
Pref = max(abs(fft(xref, M)).^2);   % peak power reference

% Medio-espectro (0..fs/2)
half = 1:(M/2);
freqs = (half-1) * (fs / M);
P_half = P_avg(half);

% convertir a dBFS
P_dbfs = 10*log10( P_half / Pref );

% Plot (simple, limpio)
figure('Name',sprintf('M=%d, γ=%.2f',M,gamma));
plot(freqs/1e6, P_dbfs, 'LineWidth', 1.2);
title(sprintf('PSD averaged, M=%d, N=%d, \\gamma=%.4g', M, Nbits, gamma));
legend('PSD (avg)');
grid on;
