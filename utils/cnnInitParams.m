function theta = cnnInitParams(imageDim,c1filterDim,c1numFilters,s2poolDim,...
    c3filterDim,c3numFilters,s4poolDim,c5Dim,c6Dim,numClasses)                         
% Initialize parameters for a single layer convolutional neural
% network followed by a softmax layer.
%                            
% Parameters:
%  imageDim   -  height/width of image
%  filterDim  -  dimension of convolutional filter                            
%  numFilters -  number of convolutional filters
%  poolDim    -  dimension of pooling area
%  numClasses -  number of classes to predict
%
% Returns:
%  theta      -  unrolled parameter vector with initialized weights

%% Initialize parameters randomly based on layer sizes.
assert(c1filterDim < imageDim,'filterDim must be less that imageDim');

Wc1 = 1e-1*randn(c1filterDim,c1filterDim,c1numFilters);
Wc3 = 1e-1*randn(c3filterDim,c3filterDim,c3numFilters);

c1outDim = imageDim - c1filterDim + 1 ; % dimension of convolved image
% assume outDim is multiple of poolDim
assert(mod(c1outDim,s2poolDim)==0,...
       's2poolDim must divide imageDim - c1filterDim + 1');
s2outDim = c1outDim/s2poolDim;
c3outDim = s2outDim - c3filterDim + 1;
assert(mod(c3outDim,s4poolDim)==0,...
        's4poolDim must divide c3outDim');
s4outDim = c3outDim/s4poolDim;

Wc5 = 1e-1*randn(c5Dim,s4outDim.^2*(c3numFilters/c1numFilters));  % here we get a sum of c3numFilters
Wc6 = 1e-1*randn(c6Dim,c5Dim);

% we'll choose weights uniformly from the interval [-r, r]
r  = sqrt(6) / sqrt(numClasses+c6Dim+1);
Wc7 = rand(numClasses, c6Dim) * 2 * r - r;

bc1 = zeros(c1numFilters, 1);
bc3 = zeros(c3numFilters/c1numFilters, 1);
bc5 = zeros(c5Dim, 1);
bc6 = zeros(c6Dim, 1);
bc7 = zeros(numClasses, 1);

% Convert weights and bias gradients to the vector form.
% This step will "unroll" (flatten and concatenate together) all 
% your parameters into a vector, which can then be used with minFunc. 
theta = [Wc1(:); Wc3(:); Wc5(:); Wc6(:); Wc7(:);...
    bc1(:); bc3(:); bc5(:); bc6(:); bc7(:)];

end

