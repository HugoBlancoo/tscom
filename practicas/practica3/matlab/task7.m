% =========================================================================
% Script: kalman_flow_rnd.m
% Subject: Signal Processing for Communications
% Assignment: Lab 3 - Linear Estimation and Kalman Filtering
% Task: 7 (Random Fluctuating Flow)
% =========================================================================

clear; clc; close all;

%% 1. SYSTEM PARAMETERS AND CONFIGURATION

% --- Physical Constants ---
rho_kgm3 = 874;
rho_gcm3 = rho_kgm3 / 1000;
ch = 0.98 * rho_gcm3;

T = 5;
diameter = 22;
radius = diameter / 2;
Area = pi * radius^2;

% --- Simulation Duration ---
duration_min = 60;
N = (duration_min * 60) / T;
num_execs = 2;

% --- True System Values ---
l_true_init = 340;
q_true_init = 33;

% --- Kalman Filter Initialization Parameters ---
mu_l = 250;
sigma_l = 11;
mu_q = 0;
sigma_q = 10;

% Measurement Noise (TWO SENSORS)
sigma_v1 = 20;
sigma_v2 = 80;
R = [sigma_v1^2,    0;
      0,        sigma_v2^2];

% --- State Space Matrices ---
A = [1,  T/Area;
     0,       1];

H = [ch, 0;
     ch, 0];

% Process Noise Covariance Q (NOW NON-ZERO!)
% Flow has random increments with std dev = 0.35 cm^3/s
sigma_flow_increment = 0.35;
Q = [0,                         0;
     0,    sigma_flow_increment^2];

% Initial Error Covariance Matrix
Sigma_init = [sigma_l^2, 0;
              0,         sigma_q^2];

%% 2. SIMULATION LOOP

figure(1); set(gcf, 'Color', 'w'); set(gca, 'Color', 'w'); hold on; grid on;
set(gca, 'GridColor', 'k', 'GridAlpha', 0.4);
title('Fluid Level Estimation (RANDOM FLOW)', 'Color', 'k', 'FontWeight', 'bold');
xlabel('Time (minutes)', 'Color', 'k'); ylabel('Level (cm)', 'Color', 'k');

figure(2); set(gcf, 'Color', 'w'); set(gca, 'Color', 'w'); hold on; grid on;
set(gca, 'GridColor', 'k', 'GridAlpha', 0.4);
title('Fluid Flow Estimation (RANDOM FLOW)', 'Color', 'k', 'FontWeight', 'bold');
xlabel('Time (minutes)', 'Color', 'k'); ylabel('Flow (cm^3/s)', 'Color', 'k');

figure(3); set(gcf, 'Color', 'w'); set(gca, 'Color', 'w'); hold on; grid on;
set(gca, 'GridColor', 'k', 'GridAlpha', 0.4);
title('Std Dev of Estimation Error (RANDOM FLOW)', 'Color', 'k', 'FontWeight', 'bold');
xlabel('Time (minutes)', 'Color', 'k'); ylabel('Std Dev', 'Color', 'k');

colors = ['b', 'r'];

for k = 1:num_execs
    
    % --- Pre-allocation ---
    s_hat_hist = zeros(2, N+1);
    Sigma_hist_l = zeros(1, N+1);
    Sigma_hist_q = zeros(1, N+1);
    x_hist = zeros(2, N+1);
    s_true_hist = zeros(2, N+1);
    
    % --- Initialization ---
    s_hat = [mu_l; mu_q];
    Sigma = Sigma_init;
    s_true = [l_true_init; q_true_init];
    
    % --- Time Loop ---
    for i = 1:(N+1)
        
        % Simulate Reality with RANDOM FLOW
        if i > 1
            % Apply deterministic dynamics
            s_true = A * s_true;
            % Add random increment to flow (process noise)
            s_true(2) = s_true(2) + sigma_flow_increment * randn;
        end
        
        % Generate TWO Measurements
        x_n = H * s_true + [sigma_v1; sigma_v2] .* randn(2, 1);
        
        % Kalman Filter Step
        
        % Prediction (now accounts for process noise Q)
        s_pred = A * s_hat;
        Sigma_pred = A * Sigma * A' + Q;
        
        % Correction
        S = H * Sigma_pred * H' + R;
        K = Sigma_pred * H' / S;
        
        s_hat = s_pred + K * (x_n - H * s_pred);
        Sigma = (eye(2) - K * H) * Sigma_pred;
        
        % Storage
        s_hat_hist(:, i) = s_hat;
        s_true_hist(:, i) = s_true;
        x_hist(:, i) = x_n;
        
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
    
    % Print asymptotic values (last 10% of simulation)
    fprintf('\n=== Execution %d ===\n', k);
    fprintf('Asymptotic Level Std: %.4f cm\n', mean(sqrt(Sigma_hist_l(end-70:end))));
    fprintf('Asymptotic Flow Std: %.4f cm^3/s\n', mean(sqrt(Sigma_hist_q(end-70:end))));
end

%% 3. FINALIZING PLOTS

time_vec = (0:N) * T / 60;

% --- Figure 1: Level ---
figure(1);
plot(time_vec, x_hist(1,:)/ch, '*', 'Color', [0.5 0.5 0.5], 'MarkerSize', 2, ...
    'DisplayName', 'Sensor 1');
plot(time_vec, x_hist(2,:)/ch, '*', 'Color', [0 0.7 0], 'MarkerSize', 2, ...
    'DisplayName', 'Sensor 2');
plot(time_vec, s_true_hist(1,:), 'k--', 'LineWidth', 1.5, 'DisplayName', 'True Level');
legend('Location', 'best', 'TextColor', 'k', 'Color', 'w', 'EdgeColor', 'k');

% --- Figure 2: Flow ---
figure(2);
plot(time_vec, s_true_hist(2,:), 'k--', 'LineWidth', 1.5, 'DisplayName', 'True Flow');
legend('Location', 'best', 'TextColor', 'k', 'Color', 'w', 'EdgeColor', 'k');

% --- Figure 3: Std Dev ---
figure(3);
legend('Location', 'best', 'TextColor', 'k', 'Color', 'w', 'EdgeColor', 'k');
title('Std Dev: Solid=Level (cm), Dashed=Flow (cm^3/s)', 'Color', 'k');
set(gca, 'YScale', 'log');
