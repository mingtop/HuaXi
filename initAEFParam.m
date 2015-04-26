function optthetaF = initAEFParam(optthetaAE,classNum,inputSize,hiddenSize)

w1 = reshape(optthetaAE(1:hiddenSize*inputSize),hiddenSize,inputSize);
b1 = reshape(optthetaAE(2*hiddenSize*inputSize+1:2*hiddenSize*inputSize+hiddenSize),hiddenSize,1);
w2 =  reshape(0.005 * randn(classNum*hiddenSize, 1),classNum,hiddenSize);
b2 = zeros(classNum,1);

optthetaF = [w1(:);w2(:);b2(:);b1(:)];
end