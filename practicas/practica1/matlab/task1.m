x = linspace(-7,7,1000);
xq = quanti(x,7,2);
xq_4 = quanti(x,7,4);

figure;
plot(x,x,'b',x,xq,'r',x,xq_4,'y');
grid on

quantized_error = x - xq;
quantized_error_4b = x - xq_4;

figure;
plot(x,quantized_error, 'r', x, quantized_error_4b, 'y');
title('Quantization Error as a Function of Input Amplitude');
xlabel('Input Amplitude');
ylabel('Quantization Error');
grid on;