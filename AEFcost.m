function [ cost,grad,err ] = AEFcost( theta,data,label, inputSize,hiddenSize ,classNum)
%AECOST Just train for one layer autoencoder 

%decode theta 
w1 = reshape(theta(1:hiddenSize*inputSize),hiddenSize,inputSize);
w2 = reshape(theta(hiddenSize*inputSize+1:hiddenSize*inputSize+classNum*hiddenSize),classNum,hiddenSize);
b1 = reshape(theta(hiddenSize*inputSize+classNum*hiddenSize+1:hiddenSize*inputSize+classNum*hiddenSize+hiddenSize),hiddenSize,1);
b2 = reshape(theta((hiddenSize*inputSize+classNum*hiddenSize+hiddenSize+1):end),classNum,1);

cost = 0;
lamdba = 0.0001;
f=@(x) 1./(1+exp(-x));
sparsityParam = 0.001;
beta = 3;
% NOTE:  Why I not reshape the data in the main programe ?
%   data here is minibatches, and it don't need too much memory
m = size(data,3);
input = reshape(data,size(data,1)*size(data,2),m);

z2 = bsxfun(@plus,w1*input,b1);
a2 = f(z2);
z3 = bsxfun(@plus,w2*a2,b2);
a3 = f(z3);

% cost 
sqCost = 1/m.*sum(sum(1/2*(label-a3).^2));
decayCost = lamdba/2*(sum(sum(w1.^2)) + sum(sum(w2.^2)));
rho = 1/m.*sum(a2,2);
sp = sparsityParam;
spCost = beta*sum(sp*log(sp./rho) + (1-sp)*log((1-sp)./(1-rho)));
cost = sqCost +  decayCost +spCost  ;

theta3 = -(label-a3).*a3.*(1-a3);
theta2 = (w2'*theta3+beta.*repmat(-sp./rho+(1-sp)./(1-rho),1,m)).*a2.*(1-a2);
gradw2 = 1/m.*theta3*a2' + lamdba*w2;
gradw1 = 1/m.*theta2*input'+lamdba*w1;
gradb2 = 1/m.*sum(theta3,2);
gradb1 = 1/m.*sum(theta2,2);

err = sqCost ;
grad = [gradw1(:);gradw2(:);gradb1(:);gradb2(:)];

end

