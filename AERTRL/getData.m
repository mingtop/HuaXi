function [ x,d,input,z ] = getData( net_AE,I,trainData )
% init data and target for RTRL 

idx = length(I);
input = trainData(:,I(randi([1,idx]),1));
[x,z] = feedforward(net_AE,input);
pImg = cnnPool(2,reshape(input,fix(sqrt(size(input,1))),fix(sqrt(size(input,1)))));
% pImg = imresize( reshape(input,28,28),0.5);% matlab linein function
d = pImg(:);


end

