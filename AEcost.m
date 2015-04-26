function [ cost,grad,err ] = AEcost( theta,data,inputSize,hiddenSize )
%AECOST Just train for one layer autoencoder 

%decode theta 
w1 = reshape(theta(1:hiddenSize*inputSize),hiddenSize,inputSize);
w2 = reshape(theta(hiddenSize*inputSize+1:2*hiddenSize*inputSize),inputSize,hiddenSize);
b1 = reshape(theta(2*hiddenSize*inputSize+1:2*hiddenSize*inputSize+hiddenSize),hiddenSize,1);
b2 = reshape(theta(2*hiddenSize*inputSize+hiddenSize+1:end),inputSize,1);
lamdba = 0.0001;
beta = 3;           % spCost param 
sparsityParam = 0.07;
cost = 0;

f=@(x) 1./(1+exp(-x));
m = size(data,3);
input = reshape(data,size(data,1)*size(data,2),m);
% label = reshape(data,size(label,1)*size(label,2),m);
z2 = bsxfun(@plus,w1*input,b1);
a2 = f(z2);
z3 = bsxfun(@plus,w2*a2,b2);
a3 = f(z3);

% cost 
sqCost = 1/m.*sum(sum(1/2*(input-a3).^2));
decayCost = lamdba/2*(sum(sum(w1.^2)) + sum(sum(w2.^2)));
rho = 1/m.*sum(a2,2);
sp = sparsityParam;
spCost = beta*sum(sp*log(sp./rho) + (1-sp)*log((1-sp)./(1-rho)));
cost = sqCost +  decayCost + spCost;

theta3 = -(input-a3).*a3.*(1-a3);
% theta2 = bsxfun(@plus,w2'*theta3,beta.*(-sp./rho+(1-sp)./(1-rho))).*a2.*(1-a2);
theta2 = (w2'*theta3+beta.*repmat(-sp./rho+(1-sp)./(1-rho),1,m)).*a2.*(1-a2);
gradw2 = 1/m.*theta3*a2' + lamdba*w2;
gradw1 = 1/m.*theta2*input'+lamdba*w1;
gradb2 = 1/m.*sum(theta3,2);
gradb1 = 1/m.*sum(theta2,2);

grad = [gradw1(:);gradw2(:);gradb1(:);gradb2(:)];
err = sqCost;


end

