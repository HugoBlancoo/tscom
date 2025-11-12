A = 1;
w0 = pi/2;
omega = linspace(-pi, pi, 2000);

W_of = @(w) ( (abs(w) <= w0) .* ( A .* (1 - abs(w)/w0) ) );

W = W_of(omega);

Lvals = [2, 3];

figure('Units','normalized','Position',[0.1 0.1 0.6 0.7]);
subplot(3,1,1);
plot(omega, W, 'LineWidth', 1.5);
xlim([-pi pi]); ylim([0 1.05*A]);
xlabel('$\omega (rad/sample)$','Interpreter','latex');
ylabel('$W(e^{j\omega})$','Interpreter','latex');
title('Original spectrum $W(e^{j\omega})$','Interpreter','latex');
grid on;

for i=1:length(Lvals)
    L = Lvals(i);
    omegaL = omega * L;
    omegaL_wrapped = mod(omegaL + pi, 2*pi) - pi;
    Wbar = W_of(omegaL_wrapped);

    subplot(3,1,i+1);
    plot(omega, Wbar, 'LineWidth', 1.5);
    xlim([-pi pi]); ylim([0 1.05*A]);
    xlabel('$\omega (rad/sample)$','Interpreter','latex');
    ylabel(['$\bar{W}(e^{j\omega})$, $L=' num2str(L) '$'],'Interpreter','latex');
    title(['Spectrum $\bar{W}(e^{j\omega}) = W(e^{j\omega ' num2str(L) '})$, $L=' num2str(L) '$'],...
          'Interpreter','latex');
    grid on;
end
