%close all;

FS = 5;
N = 10;

% (0.5*FS, 0.75*FS, FS, 1.03*FS)
A1 = 0.5*FS;
A2 = 0.75*FS;
A3 = FS;
A4 = 1.03*FS;

f0 = 18.17e6; % in Hz
numSamples = 15 * 1024;

fs = 100e6; % in Hz
t = (0:numSamples-1) / fs;

x_t1 = A1*cos(2*pi*f0*t);
x_t2 = A2*cos(2*pi*f0*t);
x_t3 = A3*cos(2*pi*f0*t);
x_t4 = A4*cos(2*pi*f0*t);

xq1 = quanti(x_t1,FS,N);
xq2 = quanti(x_t2,FS,N);
xq3 = quanti(x_t3,FS,N);
xq4 = quanti(x_t4,FS,N);

figure;
%hist(x_t-xq,40);
histogram(x_t1-xq1,40);
xlabel('Error');
ylabel('Frequency');
title('Histogram of Quantization Error for A=0.5*FS');

figure;
histogram(x_t2-xq2,40);
xlabel('Error');
ylabel('Frequency');
title('Histogram of Quantization Error for A=0.75*FS');

figure;
histogram(x_t3-xq3,40);
xlabel('Error');
ylabel('Frequency');
title('Histogram of Quantization Error for A=FS');

figure;
histogram(x_t4-xq4,40);
xlabel('Error');
ylabel('Frequency');
title('Histogram of Quantization Error for A=1.03*FS');