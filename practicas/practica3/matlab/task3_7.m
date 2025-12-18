% =========================================================================
% Script: kalman_flow_complete.m
% Subject: Signal Processing for Communications
% Assignment: Lab 3 - Linear Estimation and Kalman Filtering
% Task: 3 (Constant Fluid Level Estimation & Sensitivity Analysis)
% =========================================================================

clear; clc; close all;

%% 1. SYSTEM PARAMETERS AND CONFIGURATION
% Physical constants
rho_kgm3 = 874;                 % Density of Benzene in kg/m^3 [cite: 75]
rho_gcm3 = rho_kgm3 / 1000;     % Density in g/cm^3 (0.874)
ch = 0.98 * rho_gcm3;           % Hydrostatic constant [mbar/cm] [cite: 26]

% Simulation parameters
N = 200;                        % Number of time steps (0 to 200) [cite: 78]
num_execs = 2;                  % Number of executions for the base case

% Statistics and True Values
l_true = 340;                   % True fluid level [cm] [cite: 77]
mu_l_guess = 250;               % Initial guess for level [cm] [cite: 76]
sigma_v = 25;                   % Measurement noise std dev [mbar] [cite: 77]

% Kalman Filter Matrices (Scalar model derived in Task 3)
% State: s_n = level (constant)
A = 1;                          % State transition (level is static)
G = 0;                          % No control input
Q = 0;                          % Process noise covariance (model is perfect)
H = ch;                         % Observation matrix (converts cm to mbar)
R = sigma_v^2;                  % Measurement noise covariance

%% 2. PART A: BASELINE SIMULATION (sigma_l = 11 cm)
% We perform 2 executions to show independence of Sigma from data

sigma_l_base = 11;              % Base uncertainty [cite: 76]

% --- Prepare Figures 1 and 2 with Custom Style ---
% Figure 1: State Evolution
figure(1); 
set(gcf, 'Color', 'w'); set(gca, 'Color', 'w');
hold on; grid on;
set(gca, 'GridColor', 'k', 'GridAlpha', 0.5, 'LineWidth', 0.5);
set(gca, 'XColor', 'k', 'YColor', 'k', 'FontName', 'Helvetica', 'FontSize', 10);
title('Fig 1: Time Evolution of State and Estimates', 'Color', 'k', 'FontWeight', 'bold');
xlabel('Time index (n)', 'Color', 'k'); ylabel('Fluid Level (cm)', 'Color', 'k');

% Figure 2: Error Covariance
figure(2); 
set(gcf, 'Color', 'w'); set(gca, 'Color', 'w');
hold on; grid on;
set(gca, 'GridColor', 'k', 'GridAlpha', 0.5, 'LineWidth', 0.5);
set(gca, 'XColor', 'k', 'YColor', 'k', 'FontName', 'Helvetica', 'FontSize', 10);
title('Fig 2: Std Dev of Estimation Error (\surd\Sigma_{n|n})', 'Color', 'k', 'FontWeight', 'bold');
xlabel('Time index (n)', 'Color', 'k'); ylabel('Std Dev (cm)', 'Color', 'k');

colors = ['b', 'r']; % Colors for the two executions

for k = 1:num_execs
    % --- Initialization ---
    s_hat_hist = zeros(1, N+1);
    Sigma_hist = zeros(1, N+1);
    x_hist     = zeros(1, N+1);
    
    % Initialize Kalman Filter (n = -1)
    s_hat = mu_l_guess;
    Sigma = sigma_l_base^2;
    
    % --- Loop ---
    for i = 1:(N+1)
        % Simulate Real World
        s_n = l_true;
        v_n = sigma_v * randn; 
        x_n = H * s_n + v_n;
        
        % Kalman Filter
        % 1. Prediction
        s_pred = A * s_hat;
        Sigma_pred = A * Sigma * A' + Q;
        
        % 2. Correction
        K = Sigma_pred * H' / (H * Sigma_pred * H' + R);
        s_hat = s_pred + K * (x_n - H * s_pred);
        Sigma = (1 - K * H) * Sigma_pred;
        
        % Store
        s_hat_hist(i) = s_hat;
        Sigma_hist(i) = Sigma;
        x_hist(i)     = x_n;
    end
    
    % Plot results for execution k
    time_vec = 0:N;
    
    figure(1);
    % Plot raw measurements (scaled to cm) as dots
    plot(time_vec, x_hist/ch, '.', 'Color', [0.7 0.7 0.7], 'MarkerSize', 8, ...
        'DisplayName', sprintf('Meas. (Exec %d)', k));
    % Plot Estimate
    plot(time_vec, s_hat_hist, 'Color', colors(k), 'LineWidth', 1.5, ...
        'DisplayName', sprintf('Est. (Exec %d)', k));
        
    figure(2);
    plot(time_vec, sqrt(Sigma_hist), 'Color', colors(k), 'LineWidth', 2, ...
        'DisplayName', sprintf('Sim. Exec %d', k));
end

% Finalize Fig 1
figure(1);
plot([0 N], [l_true l_true], 'k--', 'LineWidth', 2, 'DisplayName', 'True Level');
legend('Location', 'best', 'TextColor', 'k', 'Color','w');
ylim([200 450]);

% Finalize Fig 2 (Add Analytic Curve)
figure(2);
alpha = sigma_l_base^2 / sigma_v^2;
Sigma_analytic = sigma_l_base^2 ./ (1 + ((0:N)+1) * alpha * ch^2);
plot(time_vec, sqrt(Sigma_analytic), 'g:', 'LineWidth', 2, 'DisplayName', 'Analytic Theory');
legend('Location', 'best', 'TextColor', 'k', 'Color','w');


%% 3. PART B: SENSITIVITY ANALYSIS (Varying sigma_l)
% Comparing sigma_l = 11, 50, and 5 cm [cite: 88]

sigmas_to_test = [11, 50, 5];
labels = {'\sigma_l = 11 cm (Original)', '\sigma_l = 50 cm (High Uncertainty)', '\sigma_l = 5 cm (High Confidence)'};
line_styles = {'b-', 'm-', 'g-'};

figure(3);
set(gcf, 'Color', 'w'); set(gca, 'Color', 'w');
hold on; grid on;
set(gca, 'GridColor', 'k', 'GridAlpha', 0.5);
set(gca, 'XColor', 'k', 'YColor', 'k');
title('Fig 3: Effect of Initial Uncertainty on Convergence', 'Color', 'k', 'FontWeight', 'bold');
xlabel('Time index (n)', 'Color', 'k'); ylabel('Estimate (cm)', 'Color', 'k');
plot([0 N], [l_true l_true], 'k--', 'LineWidth', 1.5, 'DisplayName', 'True Level');

% Fix random seed for fair comparison across different sigmas
rng(100); 
% Generate a single sequence of noise to use for all 3 cases
common_noise = sigma_v * randn(1, N+1);

for j = 1:length(sigmas_to_test)
    curr_sigma = sigmas_to_test(j);
    
    % Initialize
    s_hat = mu_l_guess;
    Sigma = curr_sigma^2;
    
    hist_est = zeros(1, N+1);
    
    for i = 1:(N+1)
        % Simulation (Using pre-generated noise)
        s_n = l_true;
        x_n = H * s_n + common_noise(i);
        
        % Filter
        s_pred = s_hat;
        Sigma_pred = Sigma; % Q=0
        
        K = Sigma_pred * H' / (H * Sigma_pred * H' + R);
        s_hat = s_pred + K * (x_n - H * s_pred);
        Sigma = (1 - K * H) * Sigma_pred;
        
        hist_est(i) = s_hat;
    end
    
    plot(0:N, hist_est, line_styles{j}, 'LineWidth', 2, 'DisplayName', labels{j});
end

legend('Location', 'southeast', 'TextColor', 'k', 'Color','w');
ylim([240 360]); % Zoom in to see the initial transient clearly