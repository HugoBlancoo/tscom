% seteamos seed para que el experimento sea dewterminista
rng(0)

x0=1;
Nsamples = 10 * 2^10;

FS = x0;

sigma_db = -50 : 0.1 : 0;
Nbits_list = [3,4,5,6];

% Prealocar
SQNR_emp = zeros(length(Nbits_list), length(sigma_db));
SQNR_theo = zeros(size(SQNR_emp));
% Hay que tener en cuenta el clipping debido a las 'colas' de la gaussiana
clip_prob = zeros(size(SQNR_emp));
clip_prob_emp = zeros(size(SQNR_emp));

S_all = zeros(Nsamples, length(sigma_db));

for iN = 1:length(Nbits_list)
    Nbits = Nbits_list(iN);
    L = 2^Nbits;
    step = 2*FS / L;
    for j = 1:length(sigma_db)
        sigma_dB = sigma_db(j);
        sigma_x = FS * 10^(sigma_dB/20);    % convertir dBFS -> lineal

        % generar muestras gaussianas con varianza sigma_x
        samples = sigma_x * randn(1, Nsamples);
        S_all(:,j) = samples;

        % fprintf('Vemos clipping en %d',Nbits);
        % mean(abs(samples) >= FS) %ver clipping
        clip_prob_emp(iN,j) = mean(abs(samples) >= FS);

        xq = quanti(samples, FS, Nbits);

        var_x = var(samples,1);
        var_err = var(samples - xq,1);

        % SQNR empírico
        SQNR_emp(iN,j) = 10*log10(var_x / var_err);

        % SQNR teórico
        SQNR_theo(iN,j) = 6.02*Nbits + 4.77 - 20*log10(FS / sigma_x);
    end

    % encontrar óptimo empírico
    [SQNR_max, idx_opt] = max(SQNR_emp(iN,:));
    sigma_opt = sigma_db(idx_opt);
    clip_opt = clip_prob_emp(iN, idx_opt);

     % figura mínima: SQNR y marca sigma_opt
    figure;
    plot(sigma_db, SQNR_emp(iN,:), 'b', sigma_db, SQNR_theo(iN,:), 'r--','LineWidth',1.2); hold on;
    xline(sigma_opt,'--g','LineWidth',1.2);
    xlabel('sigma_x (dBFS)'); ylabel('SQNR (dB)'); grid on;
    title(sprintf('N=%d bits — \\sigma_{opt}=%.2f dBFS, SQNR=%.2f dB', Nbits, sigma_opt, SQNR_max));
    legend('SQNR\_emp','SQNR\_theo','Location','southwest');

    % histograma del error en sigma_opt
    samples_opt = S_all(:, idx_opt);
    xq_opt = quanti(samples_opt, FS, Nbits);
    err_opt = samples_opt - xq_opt;
    figure('Color','w');
    histogram(err_opt,40);
    xlabel('Error (samples - xq)'); ylabel('Counts');
    title(sprintf('Error histogram (N=%d, \\sigma=%.2f dBFS)', Nbits, sigma_opt));
    grid on;

    % imprimir resumen por N (para copiar en el informe)
    fprintf('N=%d: sigma_opt=%.2f dBFS, SQNR_emp=%.3f dB, SQNR_theo=%.3f dB, clip_emp=%.6f\n', ...
            Nbits, sigma_opt, SQNR_max, SQNR_theo(iN, idx_opt), clip_opt);
end

% % Encontrar sigma que maximiza SQNR empírico para cada N
% opt_sigma_dB = zeros(1,length(Nbits_list));
% for iN=1:length(Nbits_list)
%     [~, idxmax] = max(SQNR_emp(iN,:));
%     fprintf('Para N: %d -> Mejor sigma: %.4f [dB]\n',Nbits_list(iN),sigma_db(idxmax));
%     fprintf('SQNR Teórico: %.4f [dB], SQNR Empírico: %.4f [dB]\n\n',SQNR_theo(iN,idxmax),SQNR_emp(iN,idxmax));
%     opt_sigma_dB(iN) = sigma_db(idxmax);
% end
