N=100000; 
sigma=1; 
s=[0 1 2 4]; 
plotStyle={'b-','r-','k-','g-'};
for i = 1: length(s)
X = s(i) + sigma.*randn(1,N); 
Y = 0 + sigma.*randn(1,N); 
Z=X+1i*Y;
[val,bin]=hist(abs(Z),1000); 
plot(bin,val/trapz(bin,val),plotStyle{i}); 

hold on;
end
for i=1:length(s)
x=s(i);
m1=sqrt(x);
m2=sqrt(x*(x-1));
r=0:0.01:9;
ss=sqrt(m1^2+m2^2);
x=r.*ss/(sigma^2);
f=r./(sigma^2).*exp(-((r.^2+ss^2)./(2*sigma^2))).*besseli(0,x);
plot(r,f,plotStyle{i},'LineWidth',2.5);
legendInfo{i} = ['s = ' num2str(s(i))];
hold on;
end
legend(legendInfo);