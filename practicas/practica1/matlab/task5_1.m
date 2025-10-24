% --- Parámetros ---
FS = 1;
x = linspace(-FS, FS, 1000);

g_0 = x;

gama_1 = 1;
g_1 = sign(x) .* (FS / log(1 + gama_1)) .* log(1 + gama_1 .* abs(x) / FS);
g_1(x == 0) = 0;

gama_2 = 2;
g_2 = sign(x) .* (FS / log(1 + gama_2)) .* log(1 + gama_2 .* abs(x) / FS);
g_2(x == 0) = 0;

% --- Dibujar ---
figure;
plot(x, g_0, 'b', 'LineWidth', 2); % gama=0 (la recta)
hold on;
plot(x, g_1, 'r', 'LineWidth', 2); % gama=1
plot(x, g_2, 'g', 'LineWidth', 2); % gama=2
grid on;
xlabel('x');
ylabel('g(x)');
title('Distortion Function g_\gamma(x)');
legend('\gamma = 0 (Ideal)', '\gamma = 1', '\gamma = 2');