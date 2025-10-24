rng(0);

x0 = 1;
sigma_x = x0 / sqrt(6);
N = 100000;

a = x0 / 2; % cada uniforme va en [-a, a]

x1 = (2*rand(N,1) - 1) * a;
x2 = (2*rand(N,1) - 1) * a;
y = x1 + x2;

mean_y = mean(y);
var_y = var(y,1);
rms_dBFS = 20*log10(sqrt(var_y)/x0);

fprintf('--- Validation ---\n');
fprintf('Expected mean = 0\n');
fprintf('Sample mean   = %.5f\n\n', mean_y);

fprintf('Expected RMS [dBFS] = -7.78\n');
fprintf('Sample RMS   [dBFS] = %g\n', rms_dBFS);

figure;
histogram(y, 100, 'Normalization', 'pdf', 'DisplayName', 'Generated samples');
hold on; grid on;

x_pdf = linspace(-x0, x0, 400);
f_pdf = (x0 - abs(x_pdf)) / (x0^2);
plot(x_pdf, f_pdf, 'r-', 'LineWidth', 2, 'DisplayName', 'Theoretical PDF');

title('Symmetric Triangular Distribution - Sum 2 dist');
xlabel('Value');
ylabel('PDF');
legend('Location','best');
hold off;
