function y = srrc(alpha, N, M);

% function y = srrc(a, N, M)
%
% Square Root Raised Cosine pulse
% Input:    a = rolloff factor
%           N = semiduration, in symbol periods
%           M = number of samples per symbol
% Output:   y = pulse samples at t = 0, +-T/M, +-2T/M,..., +-(N·M)T/M
%   thus the length of y is 2·N·M + 1

t = -N*M:N*M;
y = (sin(pi*t/M*(1-alpha)) + 4*alpha*t/M.*cos(pi*t/M*(1+alpha)))./(pi*t/M.*(1-(4*alpha*t/M).^2));

b = (t==0);

y(b) = 1-alpha+4*alpha/pi;

b = (abs(abs(t)-(M/(4*alpha))) < 10^-6);
y(b) = alpha/sqrt(2)*((1+2/pi)*sin(pi/(4*alpha)) + (1-2/pi)*cos(pi/(4*alpha)));
y = y/sqrt(y*y');
