function [Wc1, Wc3, Wc5, Wc6, Wc7, bc1, bc3, bc5, bc6, bc7] = cnnParamsToStack(theta,imageDim,...
            c1filterDim,c1numFilters,c3filterDim,c3numFilters,...
            s2poolDim,s4poolDim,c5Dim,c6Dim,numClasses)
% Converts unrolled parameters for a single layer convolutional neural
% network followed by a softmax layer into structured weight
% tensors/matrices and corresponding biases
%                            

s2outDim = (imageDim - c1filterDim + 1)/s2poolDim;
s4outDim = (s2outDim - c3filterDim + 1)/s4poolDim;
hiddenSize = s4outDim^2*(c3numFilters/c1numFilters);  % here we get a sum of c3numFilters

%% Reshape theta
indS = 1;
indE = c1filterDim^2*c1numFilters;
Wc1 = reshape(theta(indS:indE),c1filterDim,c1filterDim,c1numFilters);
indS = indE+1;
indE = indE+c3filterDim.^2*c3numFilters;
Wc3 = reshape(theta(indS:indE),c3filterDim,c3filterDim,c3numFilters);
indS = indE+1;
indE = indE+ hiddenSize*c5Dim;
Wc5 = reshape(theta(indS:indE),c5Dim,hiddenSize);
indS = indE+1;
indE = indE+ c6Dim*c5Dim;
Wc6 = reshape(theta(indS:indE),c6Dim,c5Dim);
indS = indE+1;
indE = indE+numClasses*c6Dim;
Wc7 = reshape(theta(indS:indE),numClasses,c6Dim);
indS = indE+1;
indE = indE+c1numFilters; 
bc1 = theta(indS:indE);
indS = indE+1;
indE = indE+c3numFilters/c1numFilters;
bc3 = theta(indS:indE);
indS = indE+1;
indE = indE+c5Dim;
bc5 = theta(indS:indE);
indS = indE+1;
indE = indE+c6Dim;
bc6 = theta(indS:indE);
indS = indE+1;
bc7 = theta(indS:end);

end