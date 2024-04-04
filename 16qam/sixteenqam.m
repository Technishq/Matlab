clc; clear; close all;
% Parameters
N = 100000; % Number of data bits to send over the channel
EbN0dB = -6:2:12;
% Add additional bits to make the length multiple of 4 (for 16QAM)
N = N + rem((4 - rem(N, 4)), 4);
% Generate random 1's and 0's as data
x = rand(1, N) >= 0.5;
%% 16QAM Modulation
% Group bits into groups of 4 for 16QAM mapping
inputSymBin = reshape(x, 4, N/4)';
% Convert each group of 4 bits to decimal value
b = bin2dec(num2str(inputSymBin, '%-1d'))';
% 16QAM Constellation Mapping
map = [-3 -3; -3 -1; -3 3; -3 1; -1 -3; -1 -1; -1 3; -1 1; 3 -3; 3 -1; 3 3; 3 1; 1 -3; 1 -1; 1 3; 1 1];
s = map(b(:) + 1, 1) + 1i * map(b(:) + 1, 2);
M=16; Rm=log2(M);

% Simulation for each Eb/N0 value
simulatedBER = zeros(1, length(EbN0dB));
theoreticalBER = zeros(1, length(EbN0dB));
count = 1;

for i = EbN0dB
    %-------------------------------------------
    % Channel Noise for various Eb/N0
    %-------------------------------------------
    % Adding noise with variance according to the required Eb/N0
    EbN0 = 10^(i / 10); % Converting Eb/N0 dB value to linear scale
    % Calculate the noise standard deviation
    noiseSigma = sqrt(1/(2*log2(16)*EbN0));
    
    % Creating complex noise for adding with 16QAM signal
    % Noise is complex since 16QAM is in complex representation
    n=noiseSigma*(randn(1,length(s)) + 1i*randn(1,length(s)))';
    y=s+n;

    %Plotting Constellation
    subplot(5,2,(i+6)/2+1)
    plot(real(y),imag(y),'r*');hold on;
    plot(real(s),imag(s),'ko','MarkerFaceColor','g','MarkerSize',7);hold off;
    title(['Constellation plots - ideal 16-QAM (green) Vs Noisy y signal for EbN0dB =',num2str(i),'dB']);
    
    % 16QAM Demodulation
    % Find the closest constellation point for each received symbol
    demodSymbols = zeros(1, length(y));
    for j = 1:length(y)
        [~, minindex] = min(abs(y(j) - map(:, 1) - 1i * map(:, 2)));
        demodSymbols(j) = minindex - 1;
    end
    
    % Convert demodulated symbols to binary representation
    demodBits = dec2bin(demodSymbols, 4) - '0';
    demodBits = demodBits';
    demodBits = demodBits(:)';
    
    % Calculate Bit Error Rate (BER)
    numErrors = sum(xor(x, demodBits));
    simulatedBER(count) = numErrors / N;
    theoreticalBER(count) = (2/Rm)*(1-1/sqrt(M))*erfc(sqrt((3*Rm/(2*(M-1)))*EbN0));
    count = count + 1;
end
%% BER Plotting
figure;
plot(EbN0dB, theoreticalBER, 'r-*'); hold on;
plot(EbN0dB, simulatedBER, 'k-o'); hold off;
xlabel('Eb/N0 (dB)'); ylabel('Bit Error Rate (BER)');
legend('Theoretical','Simulated')
title('16QAM Modulation and Demodulation - AWGN Channel');
grid on;

