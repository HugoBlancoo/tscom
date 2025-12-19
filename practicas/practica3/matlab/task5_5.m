% =========================================================================
% Script: kalman_flow.m
% Subject: Signal Processing for Communications
% Assignment: Lab 3 - Linear Estimation and Kalman Filtering
% Task: 5 (Simultaneous Estimation of Level and Flow)
% =========================================================================

clear; clc; close all;

%% 1. SYSTEM PARAMETERS AND CONFIGURATION

% --- Physical Constants ---
rho_kgm3 = 874;                 % Density of Benzene [kg/m^3] [cite: 75]
rho_gcm3 = rho_kgm3 / 1000;     % Density [g/cm^3]
ch = 0.98 * rho_gcm3;           % Hydrostatic constant [mbar/cm] [cite: 26]

T = 5;                          % Sampling period [s] [cite: 128]
diameter = 22;                  % Tank diameter [cm] [cite: 128]
radius = diameter / 2;
Area = pi * radius^2;           % Tank cross-section area [cm^2]

% --- Simulation Duration ---
% 60 minutes * 60 seconds / 5 seconds per sample = 720 samples
duration_min = 60;
N = (duration_min * 60) / T;    % Total time steps [cite: 132]
num_execs = 2;                  % Number of executions to plot

% --- True System Values ---
l_true_init = 340;              % Initial True Level [cm] [cite: 130]
q_true_val  = 33;               % True Flow [cm^3/s] (Constant) 

% --- Kalman Filter Initialization Parameters ---
% Level Guess
mu_l = 250;                     % Initial guess for level [cm] [cite: 130]
sigma_l = 11;                   % Uncertainty for level [cm] [cite: 130]

% Flow Guess
mu_q = 0;                       % Initial guess for flow [cm^3/s] 
sigma_q = 2;                   % Uncertainty for flow [cm^3/s] 

% Measurement Noise
sigma_v = 25;                   % Sensor noise std dev [mbar] 
R = sigma_v^2;                  % Measurement noise covariance (Scalar)

% --- State Space Matrices (2x2) ---
% State vector s_n = [level; flow]
% s_n = A * s_{n-1} + u_n (u_n=0 for this task)
A = [1,  T/Area;
     0,       1];               % derived from [cite: 115-119]

% Measurement: x_n = H * s_n + w_n
H = [ch, 0];                    % We only measure pressure (level) [cite: 121]

% Process Noise Covariance Q
% For Task 5, we assume constant flow, so the model is perfect (Q=0)
Q = zeros(2, 2); 

% Initial Error Covariance Matrix P (or Sigma)
% We assume initial errors in level and flow are uncorrelated
Sigma_init = [sigma_l^2, 0;
              0,         sigma_q^2];

%% 2. SIMULATION LOOP

% Prepare Figures with Professional Style
% Fig 1: Level Estimation
figure(1); set(gcf, 'Color', 'w'); set(gca, 'Color', 'w'); hold on; grid on;
set(gca, 'GridColor', 'k', 'GridAlpha', 0.4); set(gca, 'XColor', 'k', 'YColor', 'k');
title('Fluid Level Estimation', 'Color', 'k', 'FontWeight', 'bold');
xlabel('Time (minutes)', 'Color', 'k'); ylabel('Level (cm)', 'Color', 'k');

% Fig 2: Flow Estimation
figure(2); set(gcf, 'Color', 'w'); set(gca, 'Color', 'w'); hold on; grid on;
set(gca, 'GridColor', 'k', 'GridAlpha', 0.4); set(gca, 'XColor', 'k', 'YColor', 'k');
title('Fluid Flow Estimation', 'Color', 'k', 'FontWeight', 'bold');
xlabel('Time (minutes)', 'Color', 'k'); ylabel('Flow (cm^3/s)', 'Color', 'k');

% Fig 3: Error Std Deviation
figure(3); set(gcf, 'Color', 'w'); set(gca, 'Color', 'w'); hold on; grid on;
set(gca, 'GridColor', 'k', 'GridAlpha', 0.4); set(gca, 'XColor', 'k', 'YColor', 'k');
title('Std Dev of Estimation Error (\surd\Sigma_{n|n})', 'Color', 'k', 'FontWeight', 'bold');
xlabel('Time (minutes)', 'Color', 'k'); ylabel('Std Dev', 'Color', 'k');

colors = ['b', 'r']; % Colors for executions

for k = 1:num_execs
    
    % --- Pre-allocation ---
    s_hat_hist = zeros(2, N+1); % Rows: 1=Level, 2=Flow
    Sigma_hist_l = zeros(1, N+1); % Variance of Level
    Sigma_hist_q = zeros(1, N+1); % Variance of Flow
    x_hist = zeros(1, N+1);
    s_true_hist = zeros(2, N+1);
    
    % --- Initialization ---
    s_hat = [mu_l; mu_q];       % Initial Estimate [250; 0]
    Sigma = Sigma_init;         % Initial Covariance
    
    % True state initialization (Level starts at 340, Flow constant at 33)
    s_true = [l_true_init; q_true_val]; 
    
    % --- Time Loop ---
    for i = 1:(N+1)
        % Time in minutes for plotting
        t_min = (i-1) * T / 60;
        
        % 1. Simulate Reality
        % Update true physics (Linear evolution)
        % Note: Ideally s_true evolves using A, but since q is constant
        % and A assumes constant q, this works perfectly.
        if i > 1
             s_true = A * s_true; 
        end
        
        % Generate Measurement (Pressure from Level + Noise)
        x_n = H * s_true + sigma_v * randn;
        
        % 2. Kalman Filter Step
        
        % Prediction
        s_pred = A * s_hat;
        Sigma_pred = A * Sigma * A' + Q;
        
        % Correction
        % Innovation covariance (scalar for single sensor)
        S = H * Sigma_pred * H' + R; 
        K = Sigma_pred * H' / S;     % Kalman Gain (2x1 vector)
        
        s_hat = s_pred + K * (x_n - H * s_pred);
        Sigma = (eye(2) - K * H) * Sigma_pred;
        
        % 3. Storage
        s_hat_hist(:, i) = s_hat;
        s_true_hist(:, i) = s_true;
        x_hist(i) = x_n;
        
        % Extract diagonals of Sigma (Variances)
        Sigma_hist_l(i) = Sigma(1,1);
        Sigma_hist_q(i) = Sigma(2,2);
    end
    
    % --- Plotting Execution k ---
    time_vec = (0:N) * T / 60; % Time in minutes
    
    % Fig 1: Level
    figure(1);
    plot(time_vec, s_hat_hist(1,:), 'Color', colors(k), 'LineWidth', 1.5, ...
        'DisplayName', sprintf('Est. Exec %d', k));
    
    % Fig 2: Flow
    figure(2);
    plot(time_vec, s_hat_hist(2,:), 'Color', colors(k), 'LineWidth', 1.5, ...
        'DisplayName', sprintf('Est. Exec %d', k));
    
    % Fig 3: Error Std Dev (Level and Flow)
    figure(3);
    % Plot Level Error Std
    plot(time_vec, sqrt(Sigma_hist_l), [colors(k) '-'], 'LineWidth', 1.5, ...
        'DisplayName', sprintf('Level Std (Exec %d)', k));
    % Plot Flow Error Std
    plot(time_vec, sqrt(Sigma_hist_q), [colors(k) '--'], 'LineWidth', 1.5, ...
        'DisplayName', sprintf('Flow Std (Exec %d)', k));
end

%% 3. FINALIZING PLOTS

time_vec = (0:N) * T / 60;

% --- Figure 1: Level ---
figure(1);
% Plot Measurements (convert mbar to cm for visualization)
plot(time_vec, x_hist/ch, '.', 'Color', [0.7 0.7 0.7], 'DisplayName', 'Measurements');
% Plot True Level
plot(time_vec, s_true_hist(1,:), 'k--', 'LineWidth', 1.5, 'DisplayName', 'True Level');
legend('Location', 'best', 'TextColor', 'k', 'Color', 'w', 'EdgeColor', 'k');

% --- Figure 2: Flow ---
figure(2);
% Plot True Flow
plot(time_vec, s_true_hist(2,:), 'k--', 'LineWidth', 1.5, 'DisplayName', 'True Flow');
legend('Location', 'best', 'TextColor', 'k', 'Color', 'w', 'EdgeColor', 'k');
ylim([-10 50]); % Focus on the transition from 0 to 33

% --- Figure 3: Std Dev ---
figure(3);
legend('Location', 'best', 'TextColor', 'k', 'Color', 'w', 'EdgeColor', 'k');
title('Std Dev Error: Solid=Level (cm), Dashed=Flow (cm^3/s)', 'Color', 'k');