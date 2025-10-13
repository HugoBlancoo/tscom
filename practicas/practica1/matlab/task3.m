x0=2;
sigma0 = x0/sqrt(2);
N = 100000;
   
c = sigma0 * sqrt(3/2);

x1 = (2 * rand(N, 1) - 1) * c;
x2 = (2 * rand(N, 1) - 1) * c;

y = x1 + x2;

sample_mean = mean(y);
sample_var = var(y);
sample_rms = std(y);

fprintf('--- Validation ---\n');
fprintf('Target Mean: 0.0\n');
fprintf('Sample Mean: %f\n\n', sample_mean);

fprintf('Target Variance (sigma0^2): %f\n', sigma0^2);
fprintf('Sample Variance: %f\n\n', sample_var);

fprintf('Target RMS (sigma0): %f\n', sigma0);
fprintf('Sample RMS: %f\n\n', sample_rms);

figure;
histogram(y, 100, 'Normalization', 'pdf', 'DisplayName', 'Generated Samples');
grid on;
hold on;

a = 2*c;
x_pdf = linspace(-a, a, 400);
y_pdf = (1/a) * (1 - abs(x_pdf)/a);
plot(x_pdf, y_pdf, 'r-', 'LineWidth', 2.5, 'DisplayName', 'Theoretical PDF');

title('Symmetric Triangular Distribution');
xlabel('Random Variable Value');
ylabel('Probability Density Function (PDF)');
legend;
hold off;