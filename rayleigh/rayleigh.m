clc; clear; close all;
N=1000000; 
variance = 0.5; 
x = randn(1, N);
y = randn(1, N);
r = sqrt(variance*(x.^2 + y.^2));
step = 0.1;
range = 0:step:3;
h = hist(r, range);
approxPDF = h/(step*sum(h)); %Simulated PDF from the x and y samples
theoretical = (range/variance).*exp(-range.^2/(2*variance));
plot(range, approxPDF,'b', range, theoretical,'r*');
title('Simulated and Theoretical Rayleigh PDF for variance = 0.5')
legend('Simulated PDF','Theoretical PDF')
xlabel('r --->');
ylabel('P(r)---> ');
grid;
theta = atan(y./x);
figure(2)
hist(theta); %Plot histogram of the phase part
[counts,range] = hist(theta,100);
step=range(2)-range(1);
approxPDF = counts/(step*sum(counts)); %Simulated PDF from the x and y samples
bar(range, approxPDF,'b');
hold on
plotHandle=plot(range, approxPDF,'r');
set(plotHandle,'LineWidth',3.5);
axis([-2 2 0 max(approxPDF)+0.1])
hold off
title('Simulated PDF of Phase of Rayleigh Distribution ');
xlabel('\theta --->');
ylabel('P(\theta) --->');
grid;