x0 = 2;
A = -x0; B = 0; C = +x0; % simetría = media 0

pd = makedist('Triangular','A',A,'B',B,'C',C);
N = 10 * 2^10;
samples = random(pd, N, 1);

FS = x0;
Nbits = 3;

q_samples = quanti(samples,FS,Nbits);

figure;
histogram(samples-q_samples,40);
xlabel('Error');
ylabel('Count');
title('Histogram of Quantization Error with N=',Nbits);

%  σx varying in the range [−50,0]
sigma_db = -50 : 0.1 : 0;
Nsigs = numel(sigma_db);

Nbits_list = [3 4 5 6];

sigma_nat = FS * 10.^(sigma_db/20); % en uds naturales
sigma_base = sqrt((A^2 + B^2 + C^2 - A*B - A*C - B*C)/18); % = x0/sqrt(6)

% calculo de SQNR con la formual
SQNR_theo = zeros(numel(Nbits_list), numel(sigma_db));
for i = 1:numel(Nbits_list)
    SQNR_theo(i, :) = 6.02 * Nbits_list(i) + 4.77 + 20*log10(FS./sigma_nat);
end

%plotear (SQNR in dB vs. σx in dBFS)
figure('Color','w');
hold on;
cols = lines(numel(Nbits_list));
for i = 1:numel(Nbits_list)
    plot(sigma_db, SQNR_theo(i,:), 'LineWidth', 1.6, 'Color', cols(i,:));
end
xlabel('\sigma_x (dBFS)');
ylabel('SQNR_{theo} (dB)');
legend(arrayfun(@(n) sprintf('N = %d bits', n), Nbits_list, 'UniformOutput', false), ...
       'Location','northwest');
title('Theoretical SQNR vs \sigma_x (dBFS)');
grid on;
xlim([min(sigma_db) max(sigma_db)]);
hold off;

%valores empiricos
SQNR_emp = zeros(numel(Nbits_list), Nsigs);
for i = 1:numel(Nbits_list)
    Nbits = Nbits_list(i);
    L = 2^Nbits;
    step = 2*FS / L;                     % Δ = 2*FS / 2^N
    scales = (sigma_nat / sigma_base);% factor por cada sigma_db
    
    % Matriz señales escaladas: tamaño Nsamples x Nsigs
    X = samples * scales;           % broadcasting: columna * fila -> matriz

    % cuantizador mid-rise con saturación en [-FS, FS)
    idx = floor((X + FS) / step);        % índices antes de clip (pueden salir negativos)
    idx = min(max(idx, 0), L - 1);       % clip indices (saturación)
    Q = -FS + (idx + 0.5) * step;        % niveles cuantizados (centros)
    
    % potencias (vectorizadas por columna)
    Ps = mean( X.^2 , 1);                % 1 x Nsigs
    Pn = mean( (X - Q).^2 , 1);          % 1 x Nsigs
    SQNR_emp(i, :) = 10*log10( Ps ./ Pn );
end

%ploteamos
figure('Color','w');
hold on; box on;
for i = 1:numel(Nbits_list)
    plot(sigma_db, SQNR_emp(i,:), '-',  'LineWidth', 1.2, 'Color', cols(i,:)); % emp
    plot(sigma_db, SQNR_theo(i,:), '--', 'LineWidth', 1.6, 'Color', cols(i,:)); % theo
end
xlabel('\sigma_x (dBFS)');
ylabel('SQNR (dB)');
legend_entries = reshape([compose("Emp N=%d",Nbits_list); compose("Theo N=%d",Nbits_list)],1,[]);
legend(legend_entries,'Location','southwest');
title('Empirical (solid) vs Theoretical (dashed) SQNR — triangular signal');
grid on; xlim([min(sigma_db) max(sigma_db)]);
hold off;