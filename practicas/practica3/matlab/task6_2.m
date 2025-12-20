% =========================================================================
% Script: kalman_flow2.m
% Subject: Signal Processing for Communications
% Assignment: Lab 3 - Linear Estimation and Kalman Filtering
% Task: 6 (Estimation with TWO Pressure Sensors)
% =========================================================================

clear; clc; close all;

%% 1. SYSTEM PARAMETERS AND CONFIGURATION

% --- Physical Constants ---
rho_kgm3 = 874;                 % Density of Benzene [kg/m^3]
rho_gcm3 = rho_kgm3 / 1000;     
ch = 0.98 * rho_gcm3;           % Hydrostatic constant [mbar/cm]

T = 5;                          % Sampling period [s]
diameter = 22;                  % Tank diameter [cm]
radius = diameter / 2;
Area = pi * radius^2;           % Tank cross-section area [cm^2]

% --- Simulation Duration ---
duration_min = 60;
N = (duration_min * 60) / T;    % Total time steps
num_execs = 2;

% --- True System Values ---
l_true_init = 340;              % Initial True Level [cm]
q_true_val  = 33;               % True Flow [cm^3/s] (Constant)

% --- Kalman Filter Initialization Parameters ---
mu_l = 250;                     % Initial guess for level [cm]
sigma_l = 11;                   % Uncertainty for level [cm]
mu_q = 0;                       % Initial guess for flow [cm^3/s]
sigma_q = 10;                   % Uncertainty for flow [cm^3/s]

% Measurement Noise (TWO SENSORS with DIFFERENT variances)
sigma_v1 = 20;                  % Sensor 1 noise std dev [mbar]
sigma_v2 = 80;                  % Sensor 2 noise std dev [mbar]
R = [sigma_v1^2,    0;
      0,        sigma_v2^2];    % Measurement noise covariance (2x2)

% --- State Space Matrices ---
A = [1,  T/Area;
     0,       1];

% Measurement: TWO SENSORS, both measure pressure (i.e., level)
H = [ch, 0;
     ch, 0];                    % Both sensors measure same quantity (level)

% Process Noise Covariance Q
Q = zeros(2, 2);

% Initial Error Covariance Matrix
Sigma_init = [sigma_l^2, 0;
              0,         sigma_q^2];

%% 2. SIMULATION LOOP

% Prepare Figures
figure(1); set(gcf, 'Color', 'w'); set(gca, 'Color', 'w'); hold on; grid on;
set(gca, 'GridColor', 'k', 'GridAlpha', 0.4);
title('Fluid Level Estimation (TWO SENSORS)', 'Color', 'k', 'FontWeight', 'bold');
xlabel('Time (minutes)', 'Color', 'k'); ylabel('Level (cm)', 'Color', 'k');

figure(2); set(gcf, 'Color', 'w'); set(gca, 'Color', 'w'); hold on; grid on;
set(gca, 'GridColor', 'k', 'GridAlpha', 0.4);
title('Fluid Flow Estimation (TWO SENSORS)', 'Color', 'k', 'FontWeight', 'bold');
xlabel('Time (minutes)', 'Color', 'k'); ylabel('Flow (cm^3/s)', 'Color', 'k');

figure(3); set(gcf, 'Color', 'w'); set(gca, 'Color', 'w'); hold on; grid on;
set(gca, 'GridColor', 'k', 'GridAlpha', 0.4);
title('Std Dev of Estimation Error (TWO SENSORS)', 'Color', 'k', 'FontWeight', 'bold');
xlabel('Time (minutes)', 'Color', 'k'); ylabel('Std Dev', 'Color', 'k');

colors = ['b', 'r'];

for k = 1:num_execs
    
    % --- Pre-allocation ---
    s_hat_hist = zeros(2, N+1);
    Sigma_hist_l = zeros(1, N+1);
    Sigma_hist_q = zeros(1, N+1);
    x_hist = zeros(2, N+1);      % TWO measurements per time step
    s_true_hist = zeros(2, N+1);
    
    % --- Initialization ---
    s_hat = [mu_l; mu_q];
    Sigma = Sigma_init;
    s_true = [l_true_init; q_true_val];
    
    % --- Time Loop ---
    for i = 1:(N+1)
        
        % Simulate Reality
        if i > 1
            s_true = A * s_true;
        end
        
        % Generate TWO Measurements (from two independent sensors)
        x_n = H * s_true + [sigma_v1; sigma_v2] .* randn(2, 1);
        
        % Kalman Filter Step
        
        % Prediction
        s_pred = A * s_hat;
        Sigma_pred = A * Sigma * A' + Q;
        
        % Correction
        % Innovation covariance (now 2x2 for two measurements)
        S = H * Sigma_pred * H' + R;
        K = Sigma_pred * H' / S;     % Kalman Gain (2x2 matrix)
        
        s_hat = s_pred + K * (x_n - H * s_pred);
        Sigma = (eye(2) - K * H) * Sigma_pred;
        
        % Storage
        s_hat_hist(:, i) = s_hat;
        s_true_hist(:, i) = s_true;
        x_hist(:, i) = x_n;
        
        % Extract variances
        Sigma_hist_l(i) = Sigma(1,1);
        Sigma_hist_q(i) = Sigma(2,2);
    end
    
    % --- Plotting Execution k ---
    time_vec = (0:N) * T / 60;
    
    % Fig 1: Level
    figure(1);
    plot(time_vec, s_hat_hist(1,:), 'Color', colors(k), 'LineWidth', 1.5, ...
        'DisplayName', sprintf('Est. Exec %d', k));
    
    % Fig 2: Flow
    figure(2);
    plot(time_vec, s_hat_hist(2,:), 'Color', colors(k), 'LineWidth', 1.5, ...
        'DisplayName', sprintf('Est. Exec %d', k));
    
    % Fig 3: Error Std Dev
    figure(3);
    plot(time_vec, sqrt(Sigma_hist_l), [colors(k) '-'], 'LineWidth', 1.5, ...
        'DisplayName', sprintf('Level Std (Exec %d)', k));
    plot(time_vec, sqrt(Sigma_hist_q), [colors(k) '--'], 'LineWidth', 1.5, ...
        'DisplayName', sprintf('Flow Std (Exec %d)', k));
end

%% 3. FINALIZING PLOTS

time_vec = (0:N) * T / 60;

% --- Figure 1: Level ---
figure(1);
plot(time_vec, x_hist(1,:)/ch, '*', 'Color', [0.5 0.5 0.5], 'MarkerSize', 3, ...
    'DisplayName', 'Sensor 1');
plot(time_vec, x_hist(2,:)/ch, '*', 'Color', 'g', 'MarkerSize', 3, ...
    'DisplayName', 'Sensor 2');
plot(time_vec, s_true_hist(1,:), 'k--', 'LineWidth', 1.5, 'DisplayName', 'True Level');
legend('Location', 'best', 'TextColor', 'k', 'Color', 'w', 'EdgeColor', 'k');

% --- Figure 2: Flow ---
figure(2);
plot(time_vec, s_true_hist(2,:), 'k--', 'LineWidth', 1.5, 'DisplayName', 'True Flow');
legend('Location', 'best', 'TextColor', 'k', 'Color', 'w', 'EdgeColor', 'k');
ylim([-10 50]);

% --- Figure 3: Std Dev ---
figure(3);
legend('Location', 'best', 'TextColor', 'k', 'Color', 'w', 'EdgeColor', 'k');
title('Std Dev: Solid=Level (cm), Dashed=Flow (cm^3/s)', 'Color', 'k');
set(gca, 'YScale', 'log');

%% 4. COMPARISON FIGURE: Task 5 vs Task 6 (Std Dev)

% Re-calculate Task 5 (single sensor) covariance evolution
sigma_v5 = 25;
R_one = sigma_v5^2;
H_one = [ch, 0];

Sigma_one = Sigma_init;
Sigma_hist_l_one = zeros(1, N+1);
Sigma_hist_q_one = zeros(1, N+1);

for i = 1:(N+1)
    % Prediction
    Sigma_pred = A * Sigma_one * A' + Q;
    
    % Update with one sensor
    S = H_one * Sigma_pred * H_one' + R_one;
    K = Sigma_pred * H_one' / S;
    Sigma_one = (eye(2) - K * H_one) * Sigma_pred;
    
    % Storage
    Sigma_hist_l_one(i) = Sigma_one(1,1);
    Sigma_hist_q_one(i) = Sigma_one(2,2);
end

% Plot Comparison
figure(4); clf;
time_vec = (0:N) * T / 60;

% Level comparison
subplot(1,2,1)
semilogy(time_vec, sqrt(Sigma_hist_l), 'b-', 'LineWidth', 2.5, ...
    'DisplayName', 'Task 6 (2 sensors)'); hold on
semilogy(time_vec, sqrt(Sigma_hist_l_one), 'r-', 'LineWidth', 2.5, ...
    'DisplayName', 'Task 5 (1 sensor)');
xlabel('Time (minutes)', 'FontSize', 11);
ylabel('Std Dev (cm)', 'FontSize', 11);
title('Level Uncertainty', 'FontSize', 12, 'FontWeight', 'bold');
legend('FontSize', 10, 'Location', 'best');
grid on

% Flow comparison
subplot(1,2,2)
semilogy(time_vec, sqrt(Sigma_hist_q), 'b--', 'LineWidth', 2.5, ...
    'DisplayName', 'Task 6 (2 sensors)'); hold on
semilogy(time_vec, sqrt(Sigma_hist_q_one), 'r--', 'LineWidth', 2.5, ...
    'DisplayName', 'Task 5 (1 sensor)');
xlabel('Time (minutes)', 'FontSize', 11);
ylabel('Std Dev (cm³/s)', 'FontSize', 11);
title('Flow Uncertainty', 'FontSize', 12, 'FontWeight', 'bold');
legend('FontSize', 10, 'Location', 'best');
grid on

sgtitle('Comparison - 1 vs 2 Sensors', 'FontSize', 13, 'FontWeight', 'bold');
saveas(gcf, 'task6_comparison_std.png');
