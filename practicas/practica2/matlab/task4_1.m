% generación TX
x = OFDMmod(data, N, Lc, OF, nullpos);

% canal ideal
H = ones(N,1);

% demodulación
dem_data = OFDMdem(x, N, Lc, OF, H, nullpos);

% gráfico de constelación
figure;
scatter(real(dem_data), imag(dem_data)); 
title('Constelación recibida');
