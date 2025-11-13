% Sketch G_TX(e^{jω}) for L = 2 and L = 3 (three plots in one window)
clear; close all; clc;

% Filter design parameters
Ls = [2 3];            % upsampling factors
order = 80;            % FIR filter order
window = @hamming;     % window type
nfft = 8192;           % FFT length
omega = linspace(-pi, pi, nfft); % Frequency axis

figure('Units','normalized','Position',[0.1 0.1 0.7 0.8]);

for k = 1:length(Ls)
    L = Ls(k);
    Wn = 1/L;  % normalized cutoff (relative to Nyquist)
    
    % Design FIR lowpass interpolator
    h = fir1(order, Wn, window(order+1));
    
    % Frequency response
    H = fftshift(fft(h, nfft));
    Hmag = abs(H);
    Hdb  = 20*log10(max(Hmag,1e-12)); % avoid log(0)
    
    % ----- Subplot 1 (L=2) and Subplot 2 (L=3) -----
    subplot(3,1,k);
    plot(omega, Hmag, 'LineWidth', 1.6); hold on;
    yyaxis right;
    plot(omega, Hdb, '--', 'LineWidth', 1);
    yyaxis left;
    
    % Cutoff lines
    xline(-pi/L, '--k', 'LineWidth', 1);
    xline( pi/L, '--k', 'LineWidth', 1);
    
    % Labels and formatting
    xlabel('$\omega$ (rad/sample)','Interpreter','latex');
    yyaxis left; ylabel('$|G_{TX}(e^{j\omega})|$','Interpreter','latex');
    yyaxis right; ylabel('Magnitude (dB)','Interpreter','latex');
    title(['$G_{TX}(e^{j\omega})$ for $L = ', num2str(L), '$'],'Interpreter','latex');
    xlim([-pi pi]); grid on;
    legend({'Linear magnitude','Magnitude (dB)','$\omega_c = \pm \pi/L$'},...
        'Interpreter','latex','Location','best');
end

% ----- Subplot 3: Overlay both responses -----
subplot(3,1,3);
colors = {'b','r'};
for k = 1:length(Ls)
    L = Ls(k);
    h = fir1(order, 1/L, window(order+1));
    H = fftshift(fft(h, nfft));
    plot(omega, abs(H), 'LineWidth', 1.8, 'Color', colors{k}); hold on;
    xline(-pi/L, '--', 'Color', colors{k}, 'HandleVisibility','off');
    xline( pi/L, '--', 'Color', colors{k}, 'HandleVisibility','off');
end
xlabel('$\omega$ (rad/sample)','Interpreter','latex');
ylabel('$|G_{TX}(e^{j\omega})|$','Interpreter','latex');
title('Overlay of $G_{TX}(e^{j\omega})$ for $L=2$ and $L=3$','Interpreter','latex');
legend({'$L=2$','$L=3$'},'Interpreter','latex','Location','best');
xlim([-pi pi]); ylim([0 1.1]);
grid on;
