rng(0)

x0 = 1;
Nsamples = 10 * 2^10;

FS = x0;

sigma_db = -50 : 0.1 : 0;
Nbits_list = [3,4,5,6];

% Prealocar
SQNR_emp = zeros(length(Nbits_list), length(sigma_db));
SQNR_theo = zeros(size(SQNR_emp));

S_all = zeros(Nsamples, length(sigma_db));

for iN = 1:length(Nbits_list)
    Nbits = Nbits_list(iN);
    L = 2^Nbits;
    step = 2*FS / L;
    for j = 1:length(sigma_db)
        sigma_dB = sigma_db(j);
        sigma_x = FS * 10^(sigma_dB/20);    % convertir dBFS -> lineal

        % generar muestras triangular con varianza sigma_x
        a = sigma_x * sqrt(3/2);
        x1 = (2*rand(Nsamples,1) - 1) * a;
        x2 = (2*rand(Nsamples,1) - 1) * a;
        samples = x1 + x2;

        S_all(:,j) = samples;

        % quantize (quanti should accept column vectors)
        xq = quanti(samples, FS, Nbits);

        var_x = var(samples,1);
        var_err = var(samples - xq,1);

        % SQNR empírico
        SQNR_emp(iN,j) = 10*log10(var_x / var_err);

        % SQNR teórico (same formula as before; valid under uniform error hypothesis)
        SQNR_theo(iN,j) = 6.02*Nbits + 4.77 - 20*log10(FS / sigma_x);
    end

    % encontrar óptimo empírico
    [SQNR_max, idx_opt] = max(SQNR_emp(iN,:));
    sigma_opt = sigma_db(idx_opt);

     % plot SQNR y marca sigma_opt
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
    figure;
    histogram(err_opt,40);
    xlabel('Error (samples - xq)'); ylabel('Counts');
    title(sprintf('Error histogram (N=%d, \\sigma=%.2f dBFS) — triangular input', Nbits, sigma_opt));
    grid on;

    % imprimir resumen por N (para copiar en el informe)
    fprintf('N=%d: sigma_opt=%.2f dBFS, SQNR_emp=%.3f dB, SQNR_theo=%.3f dB\n', Nbits, sigma_opt, SQNR_max, SQNR_theo(iN, idx_opt));
end
