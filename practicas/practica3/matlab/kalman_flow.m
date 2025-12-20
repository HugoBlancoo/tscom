% kalman_flow
% Task 5: Kalman filter with varying fluid level

% Simulation parameters
rho = 0.874;            % Density of benzene, g/cm^3
cst_p = 0.98*rho;       % Measurement constant, in mbar/cm
T = 5;                  % Sampling period [s]
diameter = 22;          % Tank diameter [cm]
A_tank = pi*(diameter/2)^2; % Tank cross-section area [cm^2]

% Duration: 60 minutes
N = (60*60)/T;          % Number of iterations

% Initial guess
mean_l = 250;           % Initial guess of fluid level [cm]
var_l = 11^2;           % Variance of level guess [cm^2]
mean_q = 0;             % Initial guess of flow [cm^3/s]
var_q = 10^2;           % Variance of flow guess [(cm^3/s)^2]

% True values
l_true = 340;           % True initial level [cm]
q_true = 33;            % True flow [cm^3/s] (constant)

% Measurement noise
var_v = 25^2;           % Measurement variance [mbar^2]

% State evolution matrix
A = [1, T/A_tank; 0, 1];  % State: [level; flow]
Q = [0, 0; 0, 0];         % No process noise

% Measurement matrix (measure level only)
H = [cst_p, 0];           % H = [c_h, 0] (1x2)
R = var_v;                % Measurement noise (scalar)

% Initialization
s = [l_true; q_true];                     % True state
s_est = zeros(2, N+2);                    % State estimate
s_est(:, 1) = [mean_l; mean_q];           % Initial estimate
cov_est = zeros(2, 2, N+2);               % Covariance (2x2x(N+2))
cov_est(:, :, 1) = [var_l, 0; 0, var_q]; % Initial covariance
state = zeros(2, N+2);                    % True state history
state(:, 1) = s;
x = zeros(1, N+2);                        % Measurements

% Two independent executions
for exec = 1:2
    
    % Reset
    s = [l_true; q_true];
    s_est = zeros(2, N+2);
    s_est(:, 1) = [mean_l; mean_q];
    cov_est = zeros(2, 2, N+2);
    cov_est(:, :, 1) = [var_l, 0; 0, var_q];
    state = zeros(2, N+2);
    state(:, 1) = s;
    x = zeros(1, N+2);
    
    % Kalman filter loop
    for n = 2:N+2
        % System state update
        state(:, n) = A * state(:, n-1);
        
        % Measurement
        x(n) = H * state(:, n) + sqrt(var_v)*randn;
        
        % Kalman: Prediction
        s_pred = A * s_est(:, n-1);
        cov_pred = A * cov_est(:, :, n-1) * A' + Q;
        
        % Kalman: Update
        S = H * cov_pred * H' + R;      % Innovation covariance (scalar)
        K = cov_pred * H' / S;          % Kalman gain (2x1)
        s_est(:, n) = s_pred + K * (x(n) - H * s_pred);
        cov_est(:, :, n) = (eye(2) - K * H) * cov_pred;
    end
    
    % Store
    if exec == 1
        time = (0:N) * T / 60;
        state1 = state;
        s_est1 = s_est;
        cov_est1 = cov_est;
        x1 = x;
    else
        state2 = state;
        s_est2 = s_est;
        cov_est2 = cov_est;
        x2 = x;
    end
end

% Plot (4 subplots)
figure(1)

% Level
subplot(221)
plot(time, state1(1, 1:N+2), 'k--', time, x1(1:N+2)/cst_p, 'c*', ...
     time, s_est1(1, 1:N+2), 'b-', time, s_est2(1, 1:N+2), 'r-');
xlabel('Time (minutes)'); ylabel('Level (cm)');
legend('True', 'Measurements', 'Exec 1', 'Exec 2', 'Location', 'SouthEast')
title('Fluid Level')
grid on

% Flow
subplot(222)
plot(time, state1(2, 1:N+2), 'k--', time, s_est1(2, 1:N+2), 'b-', ...
     time, s_est2(2, 1:N+2), 'r-');
xlabel('Time (minutes)'); ylabel('Flow (cm³/s)');
legend('True', 'Exec 1', 'Exec 2', 'Location', 'SouthEast')
title('Fluid Flow')
grid on
ylim([-5, 50])

% Level std dev
subplot(223)
plot(time, sqrt(squeeze(cov_est1(1, 1, 1:N+2))), 'b-', ...
     time, sqrt(squeeze(cov_est2(1, 1, 1:N+2))), 'r-');
xlabel('Time (minutes)'); ylabel('Std Dev (cm)');
legend('Exec 1', 'Exec 2')
title('Level Error Std Dev')
set(gca, 'YScale', 'log')
grid on

% Flow std dev
subplot(224)
plot(time, sqrt(squeeze(cov_est1(2, 2, 1:N+2))), 'b-', ...
     time, sqrt(squeeze(cov_est2(2, 2, 1:N+2))), 'r-');
xlabel('Time (minutes)'); ylabel('Std Dev (cm³/s)');
legend('Exec 1', 'Exec 2')
title('Flow Error Std Dev')
set(gca, 'YScale', 'log')
grid on

sgtitle('Task 5: Varying Fluid Level (σ_q = 10 cm³/s)')
