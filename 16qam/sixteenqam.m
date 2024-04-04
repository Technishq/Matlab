clc; clear; close all;
N = 100000; 
EbN0dB = -6:2:12;
N = N + rem((4 - rem(N, 4)), 4);

x = rand(1, N) >= 0.5;
inputSymBin = reshape(x, 4, N/4)';
b = bin2dec(num2str(inputSymBin, '%-1d'))';
map = [-3 -3; -3 -1; -3 3; -3 1; -1 -3; -1 -1; -1 3; -1 1; 3 -3; 3 -1; 3 3; 3 1; 1 -3; 1 -1; 1 3; 1 1];
s = map(b(:) + 1, 1) + 1i * map(b(:) + 1, 2);
M=16; Rm=log2(M);

simulatedBER = zeros(1, length(EbN0dB));
theoreticalBER = zeros(1, length(EbN0dB));
count = 1;

for i = EbN0dB
   
      EbN0 = 10^(i / 10); 
    noiseSigma = sqrt(1/(2*log2(16)*EbN0));
    
    
    n=noiseSigma*(randn(1,length(s)) + 1i*randn(1,length(s)))';
    y=s+n;

    subplot(5,2,(i+6)/2+1)
    plot(real(y),imag(y),'r*');hold on;
    plot(real(s),imag(s),'ko','MarkerFaceColor','g','MarkerSize',7);hold off;
    title(['Constellation plots - ideal 16-QAM (green) Vs Noisy y signal for EbN0dB =',num2str(i),'dB']);
    
    demodSymbols = zeros(1, length(y));
    for j = 1:length(y)
        [~, minindex] = min(abs(y(j) - map(:, 1) - 1i * map(:, 2)));
        demodSymbols(j) = minindex - 1;
    end
    
    demodBits = dec2bin(demodSymbols, 4) - '0';
    demodBits = demodBits';
    demodBits = demodBits(:)';
    
    numErrors = sum(xor(x, demodBits));
    simulatedBER(count) = numErrors / N;
    theoreticalBER(count) = (2/Rm)*(1-1/sqrt(M))*erfc(sqrt((3*Rm/(2*(M-1)))*EbN0));
    count = count + 1;
end
figure;
plot(EbN0dB, theoreticalBER, 'r-*'); hold on;
plot(EbN0dB, simulatedBER, 'k-o'); hold off;
xlabel('Eb/N0 (dB)'); ylabel('Bit Error Rate (BER)');
legend('Theoretical','Simulated')
title('16QAM Modulation and Demodulation - AWGN Channel');
grid on;

