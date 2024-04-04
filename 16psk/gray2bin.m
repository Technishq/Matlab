function [binaryCoded]=gray2bin(grayInput)
[rows,cols]=size(grayInput);
binaryCoded=zeros(rows,cols);
for i=1:rows
binaryCoded(i,1)=grayInput(i,1);
for j=2:cols
binaryCoded(i,j)=xor(binaryCoded(i,j-1),grayInput(i,j));
end
end
end