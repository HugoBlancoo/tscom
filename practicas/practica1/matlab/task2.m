%close all;

FS = 5;
N = 10;

f0 = 18.17e6;
numSamples = 15 * 1024;

fs = 100e6;
t = (0:numSamples-1) / fs;

x_t = FS*cos(2*pi*f0*t);
xq = quanti(x_t, FS, N);
e = x_t - xq;
figure;
histogram(e,40);
xlabel('Error');
ylabel('Frequency');
title('Histogram of Quantization Error');

var_e_emp = var(e,1);
var_e_theor = (FS / 2^(N-1))^2 / 12;
fprintf('Empirical var(e) = %g; theoretical var(e) = %g\n', var_e_emp, var_e_theor);

sigma_x = sqrt(var(x,1)); % or FS / sqrt(2)

var_x_emp = var(x,1);
SQNR_emp = 10*log10(var_x_emp/var_e_emp);
SQNR_theor = 6.02*N+4.77 - 20 * log10(FS / sigma_x);
fprintf('SQNR_emp = %.4f dB; SQNR_theor = %.4f dB\n', SQNR_emp, SQNR_theor);
