x0 = 2;
A = -x0; B = 0; C = +x0; % simetría = media 0

pd = makedist('Triangular','A',A,'B',B,'C',C);
N = 100000;
samples = random(pd, N, 1);

% comprobaciones rápidas
emp_mean = mean(samples);
emp_var = var(samples);
emp_desv_std = std(samples);

% valores teoricos
% theo_mean = 0; % simetria centrado en 0
theo_var = (A^2 + B^2 + C^2 - A*B - A*C - B*C)/18;
rms = 20*log10(sqrt(theo_var)/x0);

fprintf('Theorical mean: 0; emp mean: %.2f\n',emp_mean);
fprintf('Theorical var: %.2f; emp var: %.2f\n',theo_var,emp_var);
fprintf('Sigma value: %.2f\n',sqrt(theo_var));
fprintf('rms value in dBFS: %.2f\n',rms)

% ver histograma y pdf teórica
xgrid = linspace(A,C,500)';
figure
histogram(samples,100,'Normalization','pdf')
hold on
plot(xgrid, pdf(pd,xgrid), 'LineWidth',1.5)
title('Triangular (media 0) -- muestras vs PDF')
hold off
