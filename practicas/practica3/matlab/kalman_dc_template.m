% kalman_dc_template
% 
% Simulation parameters
cst_p  = ;      % Measurement constant, in mbar/cm
mean_s = ;      % Initial guess of water level, in cm
var_s  = ()^2;  % Variance of initial guess, in cm^2
var_v  = ()^2;  % Variance of measurement errors, in mbar^2
N      = ;      % Number of iterations (the total number 
                %  of collected measurements is N+1)

% Initialization
s = ;                 % true value of the water level, in cm

s_est = zeros(1,N+2);   % Allocate memory for state estimate
s_est(1) =              % Initialize state estimate
cov_est = zeros(1,N+2); % Allocate memory for estimation error covariance
cov_est(1) =            % Initialize estimation error covariance
state = zeros(1,N+2);   % Allocate memory for system state
state(1) = s;           % Initialize system state
x = zeros(1,N+2);       % Allocate memory for observations

% Execution
for n = 2:N+2
    % System state 
    state(n) =  
    % Observation
    x(n) = cst_p*state(n) + sqrt(var_v)*randn;
    
    % Kalman filter
    s_pred =                    % State prediction, in cm
    cov_pred =                  % Prediction error covariance, in cm^2
    Kgain =                     % Kalman gain
    s_est(n) =                  % State estimate, in cm
    cov_est(n) =                % Estimation error covariance, in cm^2
end

% Plot results
subplot(211)
plot(-1:N,state,'b--',0:N,x(2:N+2),'c-',-1:N,s_est,'r-');
xlabel('sample intervals');
legend('Fluid level, cm','Observations, mbar','Level estimate, cm','Location','SouthEast')
subplot(212)
semilogy(-1:N,sqrt(cov_est),'k'); ylabel('cm'); grid on
legend('stdv of fluid level estimate')     