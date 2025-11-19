% generación TX
N = 4;
Lc = 2;
OF = 1;
nullpos = [];
data = [4 -1 4 -1 1 4i -1 2i];
[x, u, w] = OFDMmod(data, N, Lc, OF, nullpos);

% canal ideal
H = ones(N,1);

% demodulación
dem_data = OFDMdem(x, N, Lc, OF, H, nullpos);

% gráfico de constelación
figure;
scatter(real(dem_data), imag(dem_data)); 
title('Constelación recibida');
