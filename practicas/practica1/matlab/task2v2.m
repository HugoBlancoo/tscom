% Task 2: quantize a sinusoid, histogram, variance, SQNR sweep
FS = 5;
fs = 100e6;
f0 = 18.17e6;
M = 15 * 2^10;   % 15360 samples
t = (0:M-1)/fs;

% Choose amplitude A relative to FS. Start with full-scale:
A_list = [0.5, 0.75, 1.0, 1.03] * FS;   % scale factors to test
Nbits_list = [12, 10, 8, 6, 4];

results = []; % will store rows: [A, Nbits, var_e_emp, var_e_theor, SQNR_dB_emp, SQNR_dB_theor_formula]

for ai = 1:length(A_list)
    A = A_list(ai);
    x = A * cos(2*pi*f0*t);    % sinusoid
    sigma_x = A / sqrt(2);  % std of a sinusoid with amplitude A
    var_x_emp = var(x,1);      % variance of x; use normalization by N (var(x,1) --> population)
    for ni = 1:length(Nbits_list)
        Nbits = Nbits_list(ni);
        LSB = FS / 2^(Nbits-1);
        xq = quanti(x, FS, Nbits);    % quantize; use fallback if needed
        e = x - xq;
        var_e_emp = var(e,1);         % empirical variance (population)
        var_e_theor = LSB^2 / 12;    % theoretical for uniform quantizer w/o clipping

        SQNR_emp = 10*log10(var_x_emp / var_e_emp);
        % Classical formula for full-scale sine (approx):
        SQNR_theor_formula = 6.02*Nbits + 4.77 - 20 * log10(FS / sigma_x);  % dB (only valid for standard full-scale sine assumptions)

        % Save
        results = [results; A, Nbits, var_e_emp, var_e_theor, SQNR_emp, SQNR_theor_formula];
    end
end

% Display results as a Markdown-style table in the MATLAB command window:
fprintf('\n| A (dBFS) | A (abs) | Nbits | var(e) emp | var(e) theor | SQNR emp (dB) | SQNR theor (dB) |\n');
fprintf('|---:|---:|---:|---:|---:|---:|---:|\n');
for k = 1:size(results,1)
    A = results(k,1); Nbits = results(k,2);
    var_e_emp = results(k,3); var_e_theor = results(k,4);
    SQNR_emp = results(k,5); SQNR_th = results(k,6);
    % Convert amplitude to dBFS (dB relative to FS): dBFS = 20*log10(A/FS)
    dBFS = 20*log10(A/FS);
    fprintf('| %.2f dBFS | %.3f | %d | %.3e | %.3e | %.2f | %.2f |\n', dBFS, A, Nbits, var_e_emp, var_e_theor, SQNR_emp, SQNR_th);
end

% Example: plot histogram for the A = FS, Nbits = 10 case
A = FS;
Nbits = 10;
x = A * cos(2*pi*f0*t);
xq = quanti(x, FS, Nbits);
e = x - xq;
figure; histogram(e, 40);
title(sprintf('Histogram of quantization error — A=%.2f, N=%d', A, Nbits));
xlabel('error'); ylabel('count');

% Print a quick summary for that particular case
fprintf('\nExample case (A=FS, N=10):\n');
LSB = FS / 2^(10-1);
fprintf('LSB = %g\n', LSB);
fprintf('empirical var(e) = %g; theoretical var(e) = %g\n', var(e,1), LSB^2/12);
fprintf('SQNR_emp = %.2f dB; SQNR_theor (6.02N+1.76) = %.2f dB\n', 10*log10(var(x,1)/var(e,1)), 6.02*10+4.77 - 20 * log10(FS / sigma_x));
