% --- Parámetros de la simulación ---
fs = 100e6;      % 100 MHz (dado en Tarea 6 [cite: 141])
Nbits = 12;      % 12 bits (dado en Tarea 6 [cite: 141])
FS = 1;          % Full-scale
M = 1024;        % 1024-point FFT
blocks = 100;    % Promediamos 100 bloques para un espectro limpio
Nsamples = M * blocks;

% Usamos la frecuencia coherente más cercana a 40.03905 MHz
k0 = 410;
fc = k0 * fs / M; % fc = 40.0390625 MHz (Coherente)

fprintf('Simulando con fc coherente = %.6f MHz (k=%d)\n', fc/1e6, k0);

% Lista de jitters a probar
sigma_list_ps = [10, 0.1];

% Eje de frecuencia para el plot (solo de 0 a fs/2)
f_axis = (0:M/2) * fs / M;

% --- 1. Calcular Pisos de Ruido Teóricos ---
% Potencia de ruido de cuantización (fija)
Pq_dBFS = -(6.02 * Nbits + 1.76);
Pq_linear = 10^(Pq_dBFS / 10);
FFT_gain_dB = 10 * log10(M / 2);

% Loop para calcular los valores teóricos
for sigma_ps = sigma_list_ps
    sigma_tau = sigma_ps * 1e-12;
    
    % Potencia de ruido de jitter
    SNR_jitter_dB = 20 * log10(1 / (2 * pi * fc * sigma_tau));
    Pj_dBFS = -SNR_jitter_dB;
    Pj_linear = 10^(Pj_dBFS / 10);
    
    % Potencia de ruido total (suma lineal)
    P_total_linear = Pq_linear + Pj_linear;
    P_total_dBFS = 10 * log10(P_total_linear);
    
    % Piso de ruido esperado en la FFT
    Expected_Floor_dBFS = P_total_dBFS - FFT_gain_dB;
    
    fprintf('--- Caso sigma = %.1f ps ---\n', sigma_ps);
    fprintf('  P_cuantización (Pq): %.2f dBFS\n', Pq_dBFS);
    fprintf('  P_jitter (Pj):       %.2f dBFS\n', Pj_dBFS);
    fprintf('  P_ruido_total:       %.2f dBFS\n', P_total_dBFS);
    fprintf('  Piso FFT Esperado:   %.2f dBFS\n', Expected_Floor_dBFS);
    
    % Guardamos el piso esperado para plotearlo
    if sigma_ps == 10
        floor_10ps = Expected_Floor_dBFS;
    else
        floor_0_1ps = Expected_Floor_dBFS;
    end
end


% --- 2. Simulación y FFT ---
for sigma_ps = sigma_list_ps
    sigma_tau = sigma_ps * 1e-12;
    
    % a) Generar tiempos de muestreo ideales
    n = (0:Nsamples-1)';
    t_ideal = n / fs;
    
    % b) Generar el vector de jitter (ruido uniforme)
    % Si tau ~ U[-a, a], entonces sigma_tau = a / sqrt(3)
    a = sigma_tau * sqrt(3);
    tau_n = -a + (2 * a) * rand(Nsamples, 1);
    
    % c) Calcular tiempos de muestreo con jitter
    t_jittered = t_ideal + tau_n;
    
    % d) Simular la señal analógica muestreada
    % x[n] = x_c(t_ideal + tau_n) 
    xt = FS * cos(2 * pi * fc * t_jittered);
    
    % e) Cuantizar (con el cuantizador 'quanti.m')
    xq = quanti(xt, FS, Nbits);
    
    % f) Preparar para FFT (promediado de bloques)
    xq_blocks = reshape(xq, M, blocks);
    
    % g) Calcular FFT y espectro de potencia
    X_fft = fft(xq_blocks, M);
    P_avg = mean(abs(X_fft).^2, 2);
    
    % h) Normalizar a dBFS
    % Ref = Potencia de sinusoide FS coherente = (FS*M/2)^2
    norm_const = (M / 2)^2;
    P_dbfs = 10 * log10(P_avg / norm_const);
    
    % i) Plotear
    figure;
    plot(f_axis / 1e6, P_dbfs(1:M/2 + 1));
    hold on;
    
    % Dibujar la línea del piso de ruido teórico
    if sigma_ps == 10
        yline(floor_10ps, 'r--', 'LineWidth', 2, ...
            'Label', sprintf('Piso Teórico (%.1f dBFS)', floor_10ps));
    else
        yline(floor_0_1ps, 'r--', 'LineWidth', 2, ...
            'Label', sprintf('Piso Teórico (%.1f dBFS)', floor_0_1ps));
    end
    
    grid on;
    title(sprintf('Efecto del Jitter (\\sigma_{\\tau} = %.1f ps), M=1024', sigma_ps));
    xlabel('Frecuencia (MHz)');
    ylabel('Potencia (dBFS)');
    ylim([-140, 10]);
    legend('Espectro Simulado', 'Piso Teórico Esperado');
end