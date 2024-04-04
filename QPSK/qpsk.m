clc; clear; 
N = 100; 
noiseVariance = 0.5; 
data = randi([0, 3], 1, N); 

Rb = 1e3; 
amplitude = 1; 
[time, qpskData, Fs] = NRZ_Encoder(data, Rb, amplitude, 'Polar');
Tb = 1 / Rb;

subplot(4, 2, 1);
stem(data);
xlabel('Samples');
ylabel('Amplitude');
title('Input Quadrature Binary Data');
axis([0, N, -0.5, 3.5]);

subplot(4, 2, 3);
plotHandle = plot(time, qpskData);
xlabel('Time');
ylabel('Amplitude');
title('Polar QPSK encoded data');
set(plotHandle, 'LineWidth', 2.5);
maxTime = max(time);
maxAmp = max(max(real(qpskData)), max(imag(qpskData)));
minAmp = min(min(real(qpskData)), min(imag(qpskData)));
axis([0, maxTime, minAmp - 1, maxAmp + 1]);
grid on;

Fc = 2 * Rb;
oscI = cos(2 * pi * Fc * time);  
oscQ = sin(2 * pi * Fc * time); 

qpskModulated = (real(qpskData) .* oscI) + (imag(qpskData) .* oscQ);

subplot(4, 2, 5);
plot(time, qpskModulated);
xlabel('Time');
ylabel('Amplitude');
title('QPSK Modulated Data');
maxTime = max(time);
maxAmp = max(qpskModulated);
minAmp = min(qpskModulated);
axis([0, maxTime, minAmp - 1, maxAmp + 1]);

subplot(4, 2, 7);
h = spectrum.welch; 
Hpsd = psd(h, qpskModulated, 'Fs', Fs);
plot(Hpsd);
title('PSD of QPSK modulated Data');

noise = sqrt(noiseVariance) * randn(1, length(qpskModulated));
received = qpskModulated + noise;

subplot(4, 2, 2);
plot(time, received);
xlabel('Time');
ylabel('Amplitude');
title('QPSK Modulated Data with AWGN noise');

vI = received .* oscI;
vQ = received .* oscQ;

integrationBase = 0:1 / Fs:Tb - 1 / Fs;
yI = zeros(1, length(vI) / (Tb * Fs));
yQ = zeros(1, length(vQ) / (Tb * Fs));

for i = 0:(length(vI) / (Tb * Fs)) - 1
    yI(i + 1) = trapz(integrationBase, vI(int32(i * Tb * Fs + 1):int32((i + 1) * Tb * Fs)));
    yQ(i + 1) = trapz(integrationBase, vQ(int32(i * Tb * Fs + 1):int32((i + 1) * Tb * Fs)));
end

estimatedBitsI = (yI >= 0);
estimatedBitsQ = (yQ >= 0);
estimatedBits = 2 * estimatedBitsI + estimatedBitsQ;

subplot(4, 2, 4);
stem(estimatedBits);
xlabel('Samples');
ylabel('Amplitude');
title('Estimated Quadrature Binary Data');
axis([0, N, -0.5, 3.5]);

BER = sum(xor(data, estimatedBits)) / length(data);

subplot(4, 2, 6);
plot(qpskData, 'o');
xlabel('Inphase Component');
ylabel('Quadrature Phase component');
title('QPSK Constellation at Transmitter');
axis([-1.5, 1.5, -1.5, 1.5]);

subplot(4, 2, 8);
plot(yI / max(yI), yQ / max(yQ), 'o');
xlabel('Inphase Component');
ylabel('Quadrature Phase component');
title(['QPSK Constellation at Receiver when AWGN Noise Variance=', num2str(noiseVariance)]);
axis([-1.5, 1.5, -1.5, 1.5]);
