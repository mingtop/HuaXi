function theta = initAEParams(inputSize,hiddenSize)

r = sqrt(6)/sqrt(inputSize+hiddenSize+1);
w1 = 2*r*rand(hiddenSize,inputSize)-r;
w2 = 2*r*rand(inputSize,hiddenSize)-r;

b1 = zeros(hiddenSize,1);
b2 = zeros(inputSize,1);
theta = [w1(:);w2(:);b1(:);b2(:)];

end