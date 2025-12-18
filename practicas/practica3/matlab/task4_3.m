% task4_3.m - Kalman filter WITHOUT failure indicator

% Parameters
cst_p  = 1;
mean_s = 100;
var_s  = 11^2;
var_v  = 5^2;
N      = 100;

p_values = [0.15, 0.85];

figure;
for idx = 1:2
    p = p_values(idx);
    
    % Initialize
    s = 100;
    s_est = zeros(1, N+2);
    s_est(1) = mean_s;
    cov_est = zeros(1, N+2);
    cov_est(1) = var_s;
    state = zeros(1, N+2);
    state(1) = s;
    x = zeros(1, N+2);
    delta = [0, (rand(1, N+1) > p), 0];  % ACTUAL failures (hidden)
    
    % Kalman filter (assumes NO failures)
    for n = 2:N+2
        state(n) = s;
        
        if delta(n) == 1
            x(n) = cst_p * state(n) + sqrt(var_v) * randn;
        else
            x(n) = sqrt(var_v) * randn;
        end
        
        s_pred = s_est(n-1);
        cov_pred = cov_est(n-1);
        
        % Always update (NO check on delta)
        Kgain = (cst_p * cov_pred) / (cst_p^2 * cov_pred + var_v);
        s_est(n) = s_pred + Kgain * (x(n) - cst_p * s_pred);
        cov_est(n) = (1 - Kgain * cst_p) * cov_pred;
    end
    
    % Plot
    subplot(2, 2, 2*idx-1);
    plot(-1:N, state, 'b--', 'LineWidth', 1.5); hold on;
    plot(0:N, x(2:N+2), 'm*', 'MarkerSize', 4);
    plot(-1:N, s_est, 'r-', 'LineWidth', 1.5);
    xlabel('n'); ylabel('Level [cm]');
    title(sprintf('p = %.2f', p));
    legend('True', 'Meas.', 'Estimate');
    grid on;
    
    subplot(2, 2, 2*idx);
    semilogy(-1:N, sqrt(cov_est), 'k'); hold on;
    xlabel('n'); ylabel('Std [cm]');
    grid on;
    
    fprintf('p=%.2f: MSE=%.4f, Final error=%.2f cm\n', p, mean((s_est-s).^2), abs(s_est(end)-s));
end

sgtitle('Kalman without Indicator (Assumes No Failures)');
saveas(gcf, 'task4_3_results.png');
