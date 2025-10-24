% --- Parámetros Constantes ---
f0 = 37.1094e6;
M = 1024;
fs = 100e6;
blocks = 15;
FS = 1;
Nsamples = blocks * M;
f_axis = (0:M-1) * fs / M; % Eje de frecuencia
norm_const = (M / 2)^2;   % Constante de normalización (FS=1)

% --- Generar señal (una sola vez) ---
n = 0:Nsamples-1;
xt = FS * cos(2*n*pi*f0/fs);

% --- Resoluciones a probar ---
Nbits_list = [10, 8, 6];

for i = 1:length(Nbits_list)
    Nbits = Nbits_list(i); % Nbits actual
    
    % 1. Cuantizar
    xq = quanti(xt, FS, Nbits);
    
    % 2. Reformar y aplicar FFT [cite: 86, 88]
    xqblocks = reshape(xq, M, blocks);
    X = fft(xqblocks, M);
    
    % 3. Promediar y normalizar a dBFS [cite: 89]
    P_avg = mean(abs(X).^2, 2);
    P_dbfs = 10 * log10(P_avg / norm_const);
    
    % 4. Calcular piso de ruido teórico (para la leyenda)
    % SQNR = 6.02*N + 1.76
    % Piso_ruido (dBFS) = -SQNR_total - 10*log10(M/2)
    sqnr_teorico = 6.02 * Nbits + 1.76;
    piso_ruido_teorico = -sqnr_teorico - 10*log10(M/2);
    
    % 5. Graficar (en una figura nueva cada vez)
    figure; % <--- Crea una nueva figura en cada iteración
    
    plot(f_axis(1:M/2 + 1) / 1e6, P_dbfs(1:M/2 + 1), 'b');
    hold on;
    % Dibujar línea de ruido teórico
    yline(piso_ruido_teorico, 'r--', 'LineWidth', 1.5);
    hold off;
    
    grid on;
    xlabel('Frequency (MHz)');
    ylabel('Power (dBFS)');
    title(sprintf('Espectro (N = %d bits, M = 1024)', Nbits));
    ylim([-140, 10]);
    legend('Espectro medido', ...
           sprintf('Noise Floor (%.2f dBFS)', piso_ruido_teorico));
end