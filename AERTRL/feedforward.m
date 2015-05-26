function [ output,z ] = feedforward( net,input )
%  Only output the hidden layer 
%  output: is the hiddenpoint 
%  z : internal value

Sigmoid = @(x) 1./(1+exp(-x));

m = fix(length(net.layer)/2); 
for i = 1:m
    if i ==1
        z{i} = bsxfun(@plus, net.w{i}*input , net.b{i});
        a{i} = Sigmoid(z{i});
    else
        z{i} = bsxfun(@plus, net.w{i}*a{i-1} , net.b{i});
        a{i} = Sigmoid(z{i});
    end
end
output = a{i};

end

