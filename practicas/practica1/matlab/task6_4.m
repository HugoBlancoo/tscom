clear; close all; clc;

% --- 1. Definir Parámetros ---
N_bits_list = [10, 14];           % Bits
sigma_list_ps = [10, 20, 40];     % Jitter en picosegundos
fs = 100e6; % 100 MHz

% Eje de frecuencia de 0.1 MHz a 100 MHz (logarítmico)
fc = logspace(log10(0.1e6), log10(100e6), 500);

% Preparar la figura
figure;
hold on;
grid on;

% --- INICIO DE LA CORRECCIÓN ---
colors = {'b', 'r', 'g'}; % Usar {} para crear un array de celdas
% --- FIN DE LA CORRECCIÓN ---

line_styles = {'-', '--'};
legend_entries = {};

% --- 2. Bucle para calcular y graficar las 6 curvas ---
for i_N = 1:length(N_bits_list)
    N = N_bits_list(i_N);
    line_style = line_styles{i_N};
    
    % --- a) Calcular Ruido de Cuantización (SQNR) ---
    SQNR_dB = 6.02 * N + 1.76;
    P_q_rel_linear = 10^(-SQNR_dB / 10);
    
    for i_sigma = 1:length(sigma_list_ps)
        sigma_ps = sigma_list_ps(i_sigma);
        sigma_tau = sigma_ps * 1e-12; % a segundos
        
        % Ahora esto funciona
        color = colors{i_sigma}; 
        
        % --- b) Calcular Ruido de Jitter (SNR_jitter) ---
        SNR_jitter_dB = 20 * log10(1 ./ (2 * pi * fc * sigma_tau));
        P_j_rel_linear = 10.^(-SNR_jitter_dB / 10);
        
        % --- c) Calcular SNR Total ---
        P_total_rel_linear = P_q_rel_linear + P_j_rel_linear;
        SNR_total_dB = 10 * log10(1 ./ P_total_rel_linear);
        
        % --- d) Graficar ---
        plot_style = [color, line_style];
        semilogx(fc / 1e6, SNR_total_dB, plot_style, 'LineWidth', 2);
        
        legend_entries{end+1} = sprintf('N=%d bits, \\sigma_{\\tau}=%d ps', N, sigma_ps);
    end
end

% --- 3. Formatear la gráfica ---
hold off;
xlabel('Frecuencia de Entrada (MHz)', 'FontSize', 12);
ylabel('SNR Total (dB)', 'FontSize', 12);
title('SNR Total vs. Frecuencia (Jitter vs. Ruido de Cuantización)', 'FontSize', 14);
legend(legend_entries, 'Location', 'southwest');
ylim([0, 100]); 
xlim([0.1, 100]);