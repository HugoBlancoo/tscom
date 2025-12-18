% =========================================================================
% Script: kalman_flow.m
% Subject: Signal Processing for Communications
% Assignment: Lab 3 - Linear Estimation and Kalman Filtering
% Task: 3 (Constant Fluid Level Estimation)
% =========================================================================

clear; clc; close all;

%% 1. SYSTEM PARAMETERS AND CONFIGURATION
% Physical constants
rho_kgm3 = 874;                 % Density of Benzene in kg/m^3
rho_gcm3 = rho_kgm3 / 1000;     % Density in g/cm^3 (0.874)
ch = 0.98 * rho_gcm3;           % Hydrostatic constant [mbar/cm] [cite: 26]

% Simulation parameters
N = 200;                        % Number of time steps (0 to 200)
num_execs = 2;                  % Number of executions to plot

% Statistics and True Values
l_true = 340;                   % True fluid level [cm]
mu_l = 250;                     % Initial guess for level [cm]
sigma_l = 11;                   % Standard deviation of initial guess [cm]
sigma_v = 25;                   % Standard deviation of measurement noise [mbar]

% Kalman Filter Matrices (Scalar model derived in Task 3)
% State: s_n = level (constant)
A = 1;                          % State transition (level is static)
G = 0;                          % No control input
Q = 0;                          % Process noise covariance (model is perfect)
H = ch;                         % Observation matrix (converts cm to mbar)
R = sigma_v^2;                  % Measurement noise covariance

%% 2. SIMULATION LOOP (Multiple Executions)
% We use cell arrays or matrices to store data for different runs if needed,
% but for plotting we can just hold the figure.

% Prepare Figures
figure(1); hold on; grid on;
title('Time Evolution: State, Measurements, and Estimate', 'Color', 'k');
xlabel('Time index (n)'); ylabel('Fluid Level (cm)');

figure(2); hold on; grid on;
title('Standard Deviation of Estimation Error', 'Color', 'k');
xlabel('Time index (n)'); ylabel('Std Dev (cm)');

colors = ['b', 'r']; % Colors for the two executions

for k = 1:num_execs
    % --- Initialization ---
    % Pre-allocate arrays for history
    s_true_hist = zeros(1, N+1);
    x_hist      = zeros(1, N+1);
    s_hat_hist  = zeros(1, N+1);
    Sigma_hist  = zeros(1, N+1);
    
    % Initialize Kalman Filter Variables (n = -1)
    s_hat = mu_l;               % \hat{s}_{-1|-1}
    Sigma = sigma_l^2;          % \Sigma_{-1|-1} (Variance)
    
    % --- Time Loop (n = 0 to N) ---
    for i = 1:(N+1)
        n = i - 1; % Actual time index
        
        % A. Simulate Real World (The "Truth")
        s_n = l_true;           % True state is constant
        v_n = sigma_v * randn;  % Generate Gaussian noise
        x_n = H * s_n + v_n;    % Generate measurement [mbar]
        
        % B. Kalman Filter Algorithm
        
        % 1. Prediction (Time Update)
        % \hat{s}_{n|n-1} = A * \hat{s}_{n-1|n-1}
        s_pred = A * s_hat;
        % \Sigma_{n|n-1} = A * \Sigma_{n-1|n-1} * A' + Q
        Sigma_pred = A * Sigma * A' + Q;
        
        % 2. Correction (Measurement Update)
        % Kalman Gain: K_n
        K = Sigma_pred * H' / (H * Sigma_pred * H' + R);
        
        % State Update: \hat{s}_{n|n}
        s_hat = s_pred + K * (x_n - H * s_pred);
        
        % Covariance Update: \Sigma_{n|n}
        Sigma = (1 - K * H) * Sigma_pred;
        
        % C. Store Data
        s_true_hist(i) = s_n;
        x_hist(i)      = x_n;
        s_hat_hist(i)  = s_hat;
        Sigma_hist(i)  = Sigma;
    end
    
    % --- Plotting for Execution k ---
    time_vec = 0:N;
    
    % Plot on Figure 1
    figure(1);
    set(gcf, 'Color', 'w');
    set(gca, 'Color', 'w');
    grid on;
    set(gca, 'GridColor', 'k');  % 'k' es el código para negro
    set(gca, 'GridAlpha', 1);
    set(gca, 'XColor', 'k', 'YColor', 'k');
    % Plot measurements converted to cm (observed level) for valid comparison
    % We plot points (.) to avoid clutter
    plot(time_vec, x_hist/ch, '.', 'Color', [0.7 0.7 0.7], ...
        'DisplayName', sprintf('Measurements (Exec %d)', k));
    
    % Plot Estimate
    plot(time_vec, s_hat_hist, 'Color', colors(k), 'LineWidth', 1.5, ...
        'DisplayName', sprintf('Estimate (Exec %d)', k));
    
    % Plot on Figure 2 (Sigma)
    figure(2);
    set(gcf, 'Color', 'w');
    set(gca, 'Color', 'w');
    grid on;
    set(gca, 'GridColor', 'k');  % 'k' es el código para negro
    set(gca, 'GridAlpha', 1);
    set(gca, 'XColor', 'k', 'YColor', 'k');
    plot(time_vec, sqrt(Sigma_hist), 'Color', colors(k), 'LineWidth', 1.5, ...
        'DisplayName', sprintf('Exec %d', k));
end

%% 3. FINALIZING PLOTS
figure(1);
% Plot True Level once (it's the same for all)
plot(time_vec, s_true_hist, 'k--', 'LineWidth', 2, 'DisplayName', 'True Level');
legend('Location', 'best', 'Color','w', 'TextColor','k');
ylim([200 450]); % Adjust view to see convergence

figure(2);
legend('Location', 'best', 'Color','w', 'TextColor','k');
% Analytic Check (Optional validation)
% Formula: Sigma_n = sigma_l^2 / (1 + (n+1)*alpha*ch^2)
alpha = sigma_l^2 / sigma_v^2;
Sigma_analytic = sigma_l^2 ./ (1 + ((0:N)+1) * alpha * ch^2);
plot(time_vec, sqrt(Sigma_analytic), 'g:', 'LineWidth', 2, 'DisplayName', 'Analytic Theory');