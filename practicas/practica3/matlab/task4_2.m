% task4_2.m - Kalman filter WITH failure indicator
close all;

% Simulation parameters
rho = 0.874;        % Density of benzene, g/cm^3
cst_p = 0.98*rho;   % Measurement constant, in mbar/cm
mean_s = 250;       % Initial guess of fluid level, in cm
var_s = 11^2;       % Variance of initial guess, in cm^2
var_v = 25^2;       % Variance of measurement errors, in mbar^2
N = 200;            % Number of iterations
p_values = [0.15, 0.85];

figure('Position', [100 100 1200 800]);

for idx = 1:length(p_values)
    p = p_values(idx);
    
    % Initialization
    s = 340;                    % True fluid level, in cm
    s_est = zeros(1,N+2);       % State estimate
    s_est(1) = mean_s;
    cov_est = zeros(1,N+2);     % Estimation error covariance
    cov_est(1) = var_s;
    state = zeros(1,N+2);       % System state
    state(1) = s;
    x = zeros(1,N+2);           % Observations
    delta = [1, (rand(1,N+1) > p), 1];  % Failure indicator (1=no failure, 0=failure)
    
    % Kalman filter WITH failure indicator
    for n = 2:N+2
        % System state (constant)
        state(n) = s;
        
        % Observation
        if delta(n) == 1
            x(n) = cst_p*state(n) + sqrt(var_v)*randn;  % Good measurement
        else
            x(n) = sqrt(var_v)*randn;                    % Failed (pure noise)
        end
        
        % Kalman filter
        s_pred = s_est(n-1);
        cov_pred = cov_est(n-1);
        
        % Update based on failure indicator
        if delta(n) == 1
            % Normal update (measurement is reliable)
            Kgain = cst_p*cov_pred / (cst_p^2*cov_pred + var_v);
            s_est(n) = s_pred + Kgain*(x(n) - cst_p*s_pred);
            cov_est(n) = (1 - Kgain*cst_p)*cov_pred;
        else
            % Skip update (measurement is corrupted)
            s_est(n) = s_pred;
            cov_est(n) = cov_pred;
        end
    end
    
    % Plot
    subplot(2,2,2*idx-1)
    plot(-1:N, state, 'b--', 'LineWidth', 1.5); hold on
    plot(0:N, x(2:N+2), 'c*', 'MarkerSize', 4)
    plot(-1:N, s_est, 'r-', 'LineWidth', 1.5)
    xlabel('sample intervals')
    ylabel('Level (cm)')
    title(sprintf('WITH Indicator: p = %.2f', p))
    legend('True level','Observations','Estimate', 'Location', 'best')
    grid on
    
    subplot(2,2,2*idx)
    semilogy(-1:N, sqrt(cov_est), 'k', 'LineWidth', 1.5)
    xlabel('sample intervals')
    ylabel('Std Dev (cm)')
    title(sprintf('Error covariance: p = %.2f', p))
    grid on
end

sgtitle('Kalman Filter WITH Failure Indicator')
saveas(gcf, 'task4_2_results.png');
