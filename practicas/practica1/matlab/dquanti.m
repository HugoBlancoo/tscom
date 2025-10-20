function y = dquanti(x, FS, Nbits, gama)
% function  y = dquanti(x, FS, Nbits, gama)
%
% Modificación de quanti.m para incluir distorsión no lineal g(x)
%
% input:
%   x      - vector to be quantized
%   FS     - Full Scale range (from -FS to +FS)
%   Nbits  - No. of bits (including sign bit)
%   gama   - Parámetro de distorsión
%
% output: 
%   y      - quantized vector

% --- INICIO DE LA MODIFICACIÓN ---
% PASO 1: Aplicar la distorsión no lineal g(x)
% a la entrada 'x' para obtener 'g_x'
if gama == 0
    g_x = x; % Si gama=0, no hay distorsión (g(x) = x)
else
    g_x = sign(x) .* (FS / log(1 + gama)) .* log(1 + gama .* abs(x) / FS);
    g_x(x == 0) = 0;
end

FS    = abs(FS);
FSbin = 2^(Nbits-1);
LSB   = FS/FSbin;  

% Aplicamos la cuantización a 'g_x'
y = round(g_x/LSB); 

% Aplicamos la saturación
y = min(y, FSbin-1); 
y = max(y, -FSbin); 

% Devolvemos el valor cuantizado
y = y * LSB;