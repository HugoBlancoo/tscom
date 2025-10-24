rng(0)

x0 = 1;
A = -x0; B = 0; C = +x0; % simetría = media 0

pd = makedist('Triangular','A',A,'B',B,'C',C);
N = 100000;
samples = random(pd, N, 1);

emp_mean = mean(samples);
emp_var = var(samples);
emp_desv_std = std(samples);

% valores teoricos
% theo_mean = 0; % simetria centrado en 0
theo_var = (A^2 + B^2 + C^2 - A*B - A*C - B*C)/18;

rms = 20*log10(sqrt(emp_var)/x0);

fprintf('Theorical mean: 0; emp mean: %g\n',emp_mean);
fprintf('Theorical var: %.2f; emp var: %.2f\n',theo_var,emp_var);
fprintf('Sigma value: %.2f\n',sqrt(theo_var));
fprintf('rms value in dBFS: %g\n',rms)

% ver histograma y pdf teórica
xgrid = linspace(A,C,400)';
figure
histogram(samples,100,'Normalization','pdf', 'DisplayName', 'Generated samples')
hold on; grid on;

plot(xgrid, pdf(pd,xgrid), 'r-', 'LineWidth', 2, 'DisplayName', 'Theoretical PDF');

title('Symmetric Triangular Distribution - makedist');
xlabel('Value');
ylabel('PDF');
legend('Location','best');
hold off
