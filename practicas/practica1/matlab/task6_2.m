% --- Parámetros dados por el enunciado ---
Nbits = 12;          % Resolución del cuantizador
sigma_tau_ps = 20;   % Aperture jitter en picosegundos
sigma_tau = sigma_tau_ps * 1e-12; % Jitter en segundos
fc = 3e6;            % Frecuencia de la sinusoide (3 MHz)
FS = 1;              % Asumimos FS=1

% --- 1. Calcular el SNR del Jitter (Valor Fijo) ---
% Este valor es fijo porque fc y sigma_tau son fijos.
% SNR_jitter = 20 * log10(1 / (2*pi*fc*sigma_tau))
SNR_jitter_dB = 20 * log10(1 / (2 * pi * fc * sigma_tau));

fprintf('--- Tarea 6, Apartado 2 ---\n');
fprintf('Paso 1: Calcular SNR_jitter (para fc = %.1f MHz y sigma_tau = %d ps)\n', fc/1e6, sigma_tau_ps);
fprintf('  SNR_jitter = %.2f dB\n\n', SNR_jitter_dB);

% --- 2. Calcular el SQNR (Valor Variable) ---
% El SQNR depende de la amplitud de la señal, A.
% La fórmula general para una sinusoide de amplitud A (en dBFS) es:
% SQNR(A) = (6.02*N + 1.76) + A_dBFS
%
% Primero, calculamos el SQNR para escala completa (A_dBFS = 0)
SQNR_fullscale_dB = 6.02 * Nbits + 1.76;

fprintf('Paso 2: Definir el SQNR en función de la amplitud A (en dBFS)\n');
fprintf('  SQNR(A) = (6.02*N + 1.76) + A_dBFS\n');
fprintf('  SQNR(A) = %.2f dB + A_dBFS\n\n', SQNR_fullscale_dB);

% --- 3. Encontrar el punto de cruce ---
% El ruido de jitter domina cuando P_jitter > P_quant,
% lo que es lo mismo que SNR_jitter < SQNR(A).
%
% Buscamos el límite A_dBFS donde:
% SNR_jitter_dB = SQNR(A)
% SNR_jitter_dB = SQNR_fullscale_dB + A_dBFS
%
% Despejamos A_dBFS:
A_crossover_dBFS = SNR_jitter_dB - SQNR_fullscale_dB;

fprintf('Paso 3: Encontrar la amplitud A_dBFS donde SNR_jitter < SQNR(A)\n');
fprintf('  %.2f < %.2f + A_dBFS\n', SNR_jitter_dB, SQNR_fullscale_dB);
fprintf('  A_dBFS > %.2f - %.2f\n', SNR_jitter_dB, SQNR_fullscale_dB);
fprintf('  A_dBFS > %.2f dBFS\n\n', A_crossover_dBFS);

% --- 4. Conclusión ---
fprintf('--- Conclusión ---\n');
fprintf('El ruido de jitter dominará sobre el ruido de cuantización cuando\n');
fprintf('la amplitud de la señal sea mayor que %.2f dBFS.\n', A_crossover_dBFS);