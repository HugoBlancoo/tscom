% kalman_dc
% 
% Simulation parameters
rho = 0.874;        % Density of benzene, g/cm^3
cst_p = 0.98*rho;   % Measurement constant, in mbar/cm
mean_s = 250;       % Initial guess of fluid level, in cm
var_s = 11^2;       % Variance of initial guess, in cm^2
var_v = 25^2;       % Variance of measurement errors, in mbar^2
N = 200;            % Number of iterations (total measurements = N+1)

% Initialization
s = 340;                  % True fluid level, in cm
s_est = zeros(1,N+2);     % Allocate memory for state estimate
s_est(1) = mean_s;        % Initialize state estimate
cov_est = zeros(1,N+2);   % Allocate memory for estimation error covariance
cov_est(1) = var_s;       % Initialize estimation error covariance
state = zeros(1,N+2);     % Allocate memory for system state
state(1) = s;             % Initialize system state
x = zeros(1,N+2);         % Allocate memory for observations

% Execution
for n = 2:N+2
    % System state (constant)
    state(n) = s;
    
    % Observation
    x(n) = cst_p*state(n) + sqrt(var_v)*randn;
    
    % Kalman filter
    s_pred = s_est(n-1);                                              % State prediction, in cm
    cov_pred = cov_est(n-1);                                          % Prediction error covariance, in cm^2
    Kgain = cov_pred*cst_p / (cst_p^2*cov_pred + var_v);             % Kalman gain
    s_est(n) = s_pred + Kgain*(x(n) - cst_p*s_pred);                % State estimate, in cm
    cov_est(n) = (1 - Kgain*cst_p)*cov_pred;                        % Estimation error covariance, in cm^2
end

% Plot results
subplot(211)
plot(-1:N,state,'b--',0:N,x(2:N+2),'c*',-1:N,s_est,'r-');
xlabel('sample intervals');
ylabel('Level (cm)');
legend('Fluid level (true)','Observations','Level estimate','Location','SouthEast')
title('Kalman Filter: Constant Fluid Level')
grid on

subplot(212)
semilogy(-1:N,sqrt(cov_est),'k');
xlabel('sample intervals');
ylabel('cm');
legend('Std Dev of fluid level estimate')
grid on
