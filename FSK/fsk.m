clc; clear;

N = 100; 
noiseVariance = 0.5; 
data = randn(1, N) >= 0; 
Rb = 1e3; 
amplitude = 1; 

[time, nrzData, Fs] = NRZ_Encoder(data, Rb, amplitude, 'Polar');
Tb = 1 / Rb;

subplot(4, 2, 1);
stem(data);
xlabel('Samples');
ylabel('Amplitude');
title('Input Binary Data');
axis([0, N, -0.5, 1.5]);

subplot(4, 2, 3);
plotHandle = plot(time, nrzData);
xlabel('Time');
ylabel('Amplitude');
title('Polar NRZ encoded data');
set(plotHandle, 'LineWidth', 2.5);
maxTime = max(time);
maxAmp = max(nrzData);
minAmp = min(nrzData);
axis([0, maxTime, minAmp - 1, maxAmp + 1]);
grid on;

Fc1 = 2 * Rb;  
Fc2 = 4 * Rb; 
frequencies = Fc1 * ones(size(nrzData));
frequencies(nrzData == 1) = Fc2;

t = 0:1/Fs:(length(nrzData) - 1) * 1 / Fs;
fskModulated = cos(2 * pi * frequencies .* t);

subplot(4, 2, 5);
plot(time, fskModulated);
xlabel('Time');
ylabel('Amplitude');
title('FSK Modulated Data');
axis([0, maxTime, -2, 2]);

subplot(4, 2, 7);
h = spectrum.welch;  
Hpsd = psd(h, fskModulated, 'Fs', Fs);
plot(Hpsd);
title('PSD of FSK Modulated Data');

noise = sqrt(noiseVariance) * randn(1, length(fskModulated));
received = fskModulated + noise;

subplot(4, 2, 2);
plot(time, received);
xlabel('Time');
ylabel('Amplitude');
title('FSK Modulated Data with AWGN noise');

demodulated = zeros(1, length(received)/(Tb*Fs));
for i = 1:(length(received)/(Tb*Fs))
    demodulated(i) = received(i) * cos(2 * pi * Fc1 * t(i)); 
    if data(i) == 1
        demodulated(i) = received(i) * cos(2 * pi * Fc2 * t(i)); 
    end
end

estimatedBits = demodulated >= 0;

subplot(4, 2, 4);
stem(estimatedBits);
xlabel('Samples');
ylabel('Amplitude');
title('Estimated Binary Data');
axis([0, N, -0.5, 1.5]);

BER = sum(xor(data, estimatedBits)) / length(data);

subplot(4, 2, 6);
stem(nrzData, zeros(1, length(nrzData)));
xlabel('Frequency');
ylabel('Amplitude');
title('FSK Constellation at Transmitter');
axis([0, 5, -1, 1]);

subplot(4, 2, 8);
stem(demodulated / max(demodulated), zeros(1, length(demodulated)));
xlabel('Frequency');
ylabel('Amplitude');
title(['FSK Constellation at Receiver when AWGN Noise Variance=', num2str(noiseVariance)]);
axis([-1.5, 1.5, -1, 1]);
