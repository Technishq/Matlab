clc; clear; close all;
%Params
N=100000; %Number of data bits to send over the channel
EbN0dB=-6:2:12;
N = N + rem((4 - rem(N, 4)), 4);
%add additional bits to the data to make the length multiple of 4 one 16-PSK symbol contains 4 binary bits
x=rand(1,N)>=0.5;%Generate random 1's and 0's as data;
M=16; %Number of Constellation points M=2^k
Rm=log2(M); %Rm=log2(M)

%% 16PSK Modulation
%Club 4 bits together and gray code it individually
inputSymBin=reshape(x,4,N/4)';
g=bin2gray(inputSymBin);
%Convert each Gray coded symbols to decimal value this is to ease the process of mapping based on
%arrayindex
b=bin2dec(num2str(g,'%-1d'))';
%16-PSK Constellation Mapper
%16-PSK mapping Table
thetaMpsk = (0:M-1)*2*pi/M;
for i=1:M
map(i,1)=cos(thetaMpsk(i));
map(i,2)=sin(thetaMpsk(i));
end
s=map(b(:)+1,1)+1i*map(b(:)+1,2);
%Simulation for each Eb/N0 value
Rc=1; %Rc = code rate for a coded system. Since no coding is used Rc=1
simulatedBER = zeros(1,length(EbN0dB));
theoreticalBER = zeros(1,length(EbN0dB));
count=1;
figure();
%%
for i=EbN0dB
%-------------------------------------------
%Channel Noise for various Eb/N0
%-------------------------------------------
%Adding noise with variance according to the required Eb/N0
EbN0 = 10.^(i/10); %Converting Eb/N0 dB value to linear scale
noiseSigma = sqrt(2)*sqrt(1./(2*Rm*Rc*EbN0)); %Standard deviation for AWGN Noise
%Creating a complex noise for adding with 8-PSK s signal
%Noise is complex since 8-PSK is in complex representation
n = noiseSigma*(randn(1,length(s))+1i*randn(1,length(s)))';
y = s + n;

%Plotting Constellation
subplot(5,2,(i+6)/2+1)
plot(real(y),imag(y),'r*');hold on;
plot(real(s),imag(s),'ko','MarkerFaceColor','g','MarkerSize',7);hold off;
title(['Constellation plots - ideal 16-PSK (green) Vs Noisy y signal for EbN0dB =',num2str(i),'dB']);

%Demodulation
%Find the signal points from MAP table using minimum Euclidean distance
demodSymbols = zeros(1,length(y));
for j=1:length(y)
[~,minindex]=min(sqrt((real(y(j))-map(:,1)).^2+(imag(y(j))-map(:,2)).^2));
demodSymbols(j)=minindex-1;
end
demodBits=dec2bin(demodSymbols)-'0'; %Dec to binary vector
xBar=gray2bin(demodBits)'; %gray to binary
xBar=xBar(:)';
bitErrors=sum(sum(xor(x,xBar)));
simulatedBER(count) = log10(bitErrors/N);
theoreticalBER(count) = (1/Rm)*erfc(sqrt(Rm*EbN0)*sin(pi/M));
count=count+1;
end

%% BER Calculation
figure;
plot(EbN0dB,theoreticalBER,'r-*');hold on;
plot(EbN0dB,simulatedBER,'k-o');
title('BER Vs Eb/N0 (dB) for 16-PSK');legend('Theoretical','Simulated');grid on;
xlabel('Eb/N0 dB');
ylabel('BER - Bit Error Rate');

