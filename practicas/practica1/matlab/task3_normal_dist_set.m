rng(0);

x0 = 1;
sigma_x = 10^(-9.54/20); % expected value with FS = 3*sigma_x
N = 100000;

x = sigma_x * randn(1, N);

% empirical stats (population variance)
emp_mean = mean(x);
emp_var  = var(x,1);       % use var(...,1) to divide by N (population var)
rms_dBFS = 20*log10(sqrt(emp_var)/x0);

fprintf('--- Validation ---\n');
fprintf('Expected mean = 0\n');
fprintf('Sample mean   = %g\n\n', emp_mean);

fprintf('Expected RMS [dBFS] = -9.54\n');
fprintf('Sample RMS   [dBFS] = %g\n', rms_dBFS);

figure;
histogram(x, 60, 'Normalization', 'pdf');
hold on; grid on;

xx = linspace(-4*sigma_x, 4*sigma_x, 400);
plot(xx, (1/(sigma_x*sqrt(2*pi))) * exp(-0.5*(xx/sigma_x).^2), 'r-', 'LineWidth',1.5);

title('Gaussian Distribution');
xlabel('Value');
ylabel('PDF');
legend('Empirical PDF','Theoretical');
grid on; hold off;