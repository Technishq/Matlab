clc; clear; close all;
N=100000; 
EbN0dB=-6:2:12;
N = N + rem((4 - rem(N, 4)), 4);
x=rand(1,N)>=0.5;
M=16; 
Rm=log2(M); 

inputSymBin=reshape(x,4,N/4)';
g=bin2gray(inputSymBin);
b=bin2dec(num2str(g,'%-1d'))';
thetaMpsk = (0:M-1)*2*pi/M;
for i=1:M
map(i,1)=cos(thetaMpsk(i));
map(i,2)=sin(thetaMpsk(i));
end
s=map(b(:)+1,1)+1i*map(b(:)+1,2);
Rc=1; 
simulatedBER = zeros(1,length(EbN0dB));
theoreticalBER = zeros(1,length(EbN0dB));
count=1;
figure();

for i=EbN0dB
EbN0 = 10.^(i/10); 
noiseSigma = sqrt(2)*sqrt(1./(2*Rm*Rc*EbN0)); 
n = noiseSigma*(randn(1,length(s))+1i*randn(1,length(s)))';
y = s + n;

subplot(5,2,(i+6)/2+1)
plot(real(y),imag(y),'r*');hold on;
plot(real(s),imag(s),'ko','MarkerFaceColor','g','MarkerSize',7);hold off;
title(['Constellation plots - ideal 16-PSK (green) Vs Noisy y signal for EbN0dB =',num2str(i),'dB']);

demodSymbols = zeros(1,length(y));
for j=1:length(y)
[~,minindex]=min(sqrt((real(y(j))-map(:,1)).^2+(imag(y(j))-map(:,2)).^2));
demodSymbols(j)=minindex-1;
end
demodBits=dec2bin(demodSymbols)-'0'; 
xBar=gray2bin(demodBits)'; 
xBar=xBar(:)';
bitErrors=sum(sum(xor(x,xBar)));
simulatedBER(count) = log10(bitErrors/N);
theoreticalBER(count) = (1/Rm)*erfc(sqrt(Rm*EbN0)*sin(pi/M));
count=count+1;
end

figure;
plot(EbN0dB,theoreticalBER,'r-*');hold on;
plot(EbN0dB,simulatedBER,'k-o');
title('BER Vs Eb/N0 (dB) for 16-PSK');legend('Theoretical','Simulated');grid on;
xlabel('Eb/N0 dB');
ylabel('BER - Bit Error Rate');

