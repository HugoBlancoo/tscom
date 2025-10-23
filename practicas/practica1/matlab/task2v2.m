FS = 5;
fs = 100e6;
f0 = 18.17e6;
M = 15 * 2^10;
t = (0:M-1)/fs;

A_list = [0.5, 0.75, 1.0, 1.03] * FS;
Nbits_list = [12, 10, 8, 6, 4];

results = [];

for A = A_list
    x = A * cos(2*pi*f0*t);
    sigma_x = A / sqrt(2);
    var_x_emp = var(x,1);
    for Nbits = Nbits_list
        LSB = FS / 2^(Nbits-1);
        xq = quanti(x, FS, Nbits);

        e = x - xq;
        var_e_emp = var(e,1);
        var_e_theor = LSB^2 / 12;

        SQNR_emp = 10*log10(var_x_emp / var_e_emp);
        SQNR_theor_formula = 6.02*Nbits + 4.77 - 20 * log10(FS / sigma_x);

        % Save
        results = [results; A, Nbits, var_e_emp, var_e_theor, SQNR_emp, SQNR_theor_formula];
    end
end

fprintf('\n| A (dBFS) | A (abs) | Nbits | var(e) emp | var(e) theor | SQNR theor (dB) | SQNR emp (dB) | \n');
fprintf('|---:|---:|---:|---:|---:|---:|---:|\n');
for k = 1:size(results,1)
    A = results(k,1); Nbits = results(k,2);
    var_e_emp = results(k,3); var_e_theor = results(k,4);
    SQNR_emp = results(k,5); SQNR_th = results(k,6);
    % Convert amplitude to dBFS (dB relative to FS): dBFS = 20*log10(A/FS)
    dBFS = 20*log10(A/FS);
    fprintf('| %.2f dBFS | %.3f | %d | %.3e | %.3e | %.2f | %.2f |\n', dBFS, A, Nbits, var_e_emp, var_e_theor, SQNR_th, SQNR_emp);
end
