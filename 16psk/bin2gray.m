function [grayCoded]=bin2gray(binaryInput)
[rows,cols]=size(binaryInput);
grayCoded=zeros(rows,cols);
for i=1:rows
grayCoded(i,:)=[binaryInput(i,1) xor(binaryInput(i,2:cols),binaryInput(i,1:cols-1))];
end
end