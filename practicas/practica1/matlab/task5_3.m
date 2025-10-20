% --- Parámetros de la Tarea 5.3 ---
f0 = 6.8359e6;       % Frecuencia (NO COHERENTE)
fs = 100e6;
Nbits = 11;
FS = 1;
gama = 0.003;
blocks = 15; % Usamos 15 bloques como en Tarea 4
M_list = [2048, 512]; % Tamaños de FFT

% --- Bucle para analizar cada M ---
for M = M_list
    
    % 1. Generar FS sinusoidal (Nsamples = 15 * M)
    Nsamples = blocks * M;
    n = 0:Nsamples-1; 
    xt = FS * cos(2*pi*f0/fs * n);
    
    % 2. Cuantizar con distorsión
    xq = dquanti(xt, FS, Nbits, gama);
    
    % 3. Reformar en bloques (reshape)
    xqblocks = reshape(xq, M, blocks);
    
    % 4. Calcular FFT (¡SIN VENTANA!)
    X = fft(xqblocks, M);
    
    % 5. Promediar la potencia
    P_avg = mean(abs(X).^2, 2); % Promedio sobre los 15 bloques

    % 6. Normalizar a dBFS
    norm_const = (M / 2)^2;
    P_dbfs = 10 * log10(P_avg / norm_const);
    f_axis = (0:M/2) * fs / M;

    % 7. Calcular SFDR (¡¡Este resultado será INCORRECTO!!)
    [P_signal, idx_signal] = max(P_dbfs(1:end));
    
    P_dbfs_no_signal = P_dbfs;
    blank_width_bins = 10; 
    idx_start = max(1, idx_signal - blank_width_bins);
    idx_end = min(length(P_dbfs), idx_signal + blank_width_bins);
    P_dbfs_no_signal(idx_start:idx_end) = -Inf;
    
    [P_spur, idx_spur] = max(P_dbfs_no_signal);
    
    SFDR_dBFS = 0 - P_spur;

    % 8. Graficar y mostrar resultados
    figure; 
    plot(f_axis / 1e6, P_dbfs);
    hold on;
    plot(f_axis(idx_signal)/1e6, P_signal, 'rs', 'MarkerSize', 10);
    plot(f_axis(idx_spur)/1e6, P_spur, 'gv', 'MarkerSize', 10);
    hold off;
    
    grid on;
    xlabel('Frecuencia (MHz)');
    ylabel('Potencia (dBFS)');
    title(sprintf('Espectro (Método T4) (M=%d, \\gamma=%.3f)', M, gama));
    ylim([-160, 10]);
    legend('Espectro (con fuga)', 'Pico Señal', 'Falso Espurio (Fuga)');
    
    fprintf('--- Resultados (Método T4, SIN ventana) para M = %d ---\n', M);
    fprintf('Pico Señal:   %.2f dBFS\n', P_signal);
    fprintf('Pico Falso Espurio (Fuga): %.2f dBFS\n', P_spur);
    fprintf('SFDR (FALSO):             %.2f dBFS\n\n', SFDR_dBFS);
    
end