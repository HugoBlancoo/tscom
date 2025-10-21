% --- Parámetros dados por el enunciado ---
Nbits = 12;          % Resolución del cuantizador
sigma_tau_ps = 20;   % Aperture jitter en picosegundos
sigma_tau = sigma_tau_ps * 1e-12; % Jitter en segundos

% --- 1. Calcular el SQNR (Ruido de Cuantización) ---
% Para una sinusoide full-scale 
SQNR_dB = 6.02 * Nbits + 1.76;

fprintf('Paso 1: El SQNR de cuantización (N=%d bits) es %.2f dB.\n', Nbits, SQNR_dB);

% --- 2. Encontrar la frecuencia de cruce (fc) ---
% El ruido de jitter domina cuando SNR_jitter < SQNR.
% Buscamos el límite donde SNR_jitter = SQNR_dB.
%
% Ecuación: 20 * log10(1 / (2*pi*fc*sigma_tau)) = SQNR_dB

% Despejamos fc:
% log10(1 / (2*pi*fc*sigma_tau)) = SQNR_dB / 20
% 1 / (2*pi*fc*sigma_tau) = 10^(SQNR_dB / 20)
% fc = 1 / ( 10^(SQNR_dB / 20) * 2*pi*sigma_tau )

ratio_lineal = 10^(SQNR_dB / 20);
fc_crossover = 1 / ( ratio_lineal * 2 * pi * sigma_tau );

fprintf('Paso 2: El SNR del jitter es 20*log10(1 / (2*pi*fc*%.0fps)).\n', sigma_tau_ps);
fprintf('Paso 3: Igualamos las dos ecuaciones para encontrar el cruce.\n');
fprintf('       fc = 1 / ( 10^(%.2f / 20) * 2*pi*%.0e )\n', SQNR_dB, sigma_tau);
fprintf('       La frecuencia de cruce es fc = %.3f MHz\n', fc_crossover / 1e6);

% --- 4. Conclusión ---
fprintf('\n--- Conclusión ---\n');
fprintf('La potencia del error de apertura (jitter) dominará sobre la potencia\n');
fprintf('del ruido de cuantización cuando fc > %.3f MHz.\n', fc_crossover / 1e6);