    % Task5_SFDR_vs_M_minimal.m
    clear; close all; clc;
    rng(0);
    
    % --- Parámetros Constantes ---
    f0 = 6.8359e6;       % Hz (full-scale sinusoid freq)
    fs = 100e6;          % sample rate
    FS = 1;              % full-scale amplitude (±FS)
    gamma = 0.003;       % no-linearidad
    Nbits = 11;          % bits para dquanti
    M_list = [2048, 512];
    blocks = 15;         % 15 bloques como pide la práctica
    
    % Result container
    results = struct('M', {}, 'fund_freq_MHz', {}, 'fund_level_dBFS', {}, ...
        'largest_spur_dBFS', {}, 'spur_freq_MHz', {}, 'SFDR_dB', {}, 'noise_floor_dBFS', {});
    
    for im = 1:length(M_list)
        M = M_list(im);
        Nsamples = blocks * M;
        n = (0:Nsamples-1).';                     % columna
        % generar full-scale sinusoid
        xt = FS * cos(2*pi*f0/fs * n);            % columna
    
        % cuantizar con dquanti (aplica g_gamma + cuantizador uniforme)
        xq = dquanti(xt, FS, Nbits, gamma);
    
        % reordenar en bloques M x blocks
        xqblocks = reshape(xq, M, blocks);
    
        % FFT columnwise
        X = fft(xqblocks, M);
    
        % Promedio de potencia por bin (power)
        Pavg = mean(abs(X).^2, 2);    % M x 1 (power per bin)
    
        % Referencia para dBFS: potencia máxima de un coseno full-scale alineado con bin k0
        k0 = round(f0 * M / fs);      % bin aproximado de f0
        % referencia: bloquear una señal exactamente en el bin k0 (un bloque)
        n0 = (0:M-1).';
        xref = FS * cos(2*pi*(k0/M) * n0);
        Pref = max(abs(fft(xref, M)).^2);   % peak power reference
    
        % Medio-espectro (0..fs/2)
        half = 1:(M/2);
        freqs = (half-1) * (fs / M);
        P_half = Pavg(half);
    
        % convertir a dBFS (potencia)
        P_dbfs = 10*log10( P_half / Pref );
    
        % localizar fundamental: el bin más cercano a f0
        [~, idx_fund] = min(abs(freqs - f0));
        fund_level = P_dbfs(idx_fund);
    
        % máscara para excluir DC y +/-1 bins alrededor del fundamental
        ignore_bw = 0;
        mask = true(size(P_dbfs));
        mask(1) = false;  % excluir DC
        low = max(1, idx_fund - ignore_bw);
        high = min(length(P_dbfs), idx_fund + ignore_bw);
        mask(low:high) = false;
    
        % hallar mayor spur en el resto del espectro (en dBFS)
        if any(mask)
            spur_level = max(P_dbfs(mask));
            tmp_idx = find(mask);
            spur_idx_rel = find(P_dbfs(tmp_idx) == spur_level, 1, 'first');
            spur_idx_global = tmp_idx(spur_idx_rel);
            spur_freq = freqs(spur_idx_global);
        else
            spur_level = -Inf;
            spur_idx_global = NaN;
            spur_freq = NaN;
        end
        SFDR = fund_level - spur_level;
    
        % estimar noise floor (promedio en potencia de bins en mask)
        noise_floor_db = 10*log10(mean(10.^(P_dbfs(mask)/10)));
    
        % guardar resultados
        res.M = M;
        res.fund_freq_MHz = freqs(idx_fund)/1e6;
        res.fund_level_dBFS = fund_level;
        res.largest_spur_dBFS = spur_level;
        res.spur_freq_MHz = spur_freq/1e6;
        res.SFDR_dB = SFDR;
        res.noise_floor_dBFS = noise_floor_db;
        results{im} = res;
    
        % Plot (simple, limpio)
        figure('Name',sprintf('M=%d',M));
        plot(freqs/1e6, P_dbfs, 'LineWidth', 1.2); hold on;
        plot(freqs(idx_fund)/1e6, fund_level, 'go','MarkerFaceColor','g');
        if ~isnan(spur_idx_global)
            plot(freqs(spur_idx_global)/1e6, spur_level, 'ro','MarkerFaceColor','r');
        end
        xlabel('Frequency (MHz)'); ylabel('Power (dBFS)');
        title(sprintf('PSD averaged, M=%d, N=%d, \\gamma=%.4g', M, Nbits, gamma));
        legend('PSD (avg)','Fundamental','Largest spur','Location','southwest');
        text(0.02*fs/1e6, max(P_dbfs)-5, sprintf('SFDR = %.2f dB\nNoise floor = %.2f dBFS', SFDR, noise_floor_db));
        grid on; xlim([0 fs/2]/1e6);
        ylim([max(P_dbfs)-80, max(P_dbfs)+5]);
        hold off;
    end
    
    % mostrar tabla con resultados
    T = struct2table([results{:}]);
    disp(T);
    writetable(T,'task5_sfdr_results.csv');