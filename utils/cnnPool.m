function pooledFeatures = cnnPool(poolDim, convolvedFeatures)
%cnnPool Pools the given convolved features
%
% Parameters:
%  poolDim - dimension of pooling region
%  convolvedFeatures - convolved features to pool (as given by cnnConvolve)
%                      convolvedFeatures(imageRow, imageCol, featureNum, imageNum)
%
% Returns:
%  pooledFeatures - matrix of pooled features in the form
%                   pooledFeatures(poolRow, poolCol, featureNum, imageNum)
%

numImages = size(convolvedFeatures, 4);
numFilters = size(convolvedFeatures, 3);
convolvedDim = size(convolvedFeatures, 1);

pooledFeatures = zeros(convolvedDim / poolDim, ...
    convolvedDim / poolDim, numFilters, numImages);

% Instructions:
%   Now pool the convolved features in regions of poolDim x poolDim,
%   to obtain the
%   (convolvedDim/poolDim) x (convolvedDim/poolDim) x numFeatures x numImages
%   matrix pooledFeatures, such that
%   pooledFeatures(poolRow, poolCol, featureNum, imageNum) is the
%   value of the featureNum feature for the imageNum image pooled over the
%   corresponding (poolRow, poolCol) pooling region.
%
%   Use mean pooling here.

%%% YOUR CODE HERE %%%   ---by Jamin
for imageNum = 1:numImages
    for filterNum = 1:numFilters
        poolImage = zeros(convolvedDim/poolDim,convolvedDim/poolDim);
        filter = (1/poolDim.^2)*ones(poolDim);
        poolImage = conv2(squeeze(convolvedFeatures(:,:,filterNum,imageNum)),filter,'valid');
%         %method 1 with 3 circle
%         indx = [];   % avoiding 4-D iterator 
%         for i = 1:convolvedDim
%             if mod(i,poolDim)==1
%                 indx=[indx,i];
%             end
%         end
%         pooledFeatures(:,:,filterNum,imageNum) = poolImage(indx,indx);
        % Method 2, only two circle
        indx = 1:convolvedDim;
        indx = find(mod(indx,poolDim)==0);         % find the indx 
        indx = bsxfun(@minus,indx,poolDim-1);      % get the right indx    
        pooledFeatures(:,:,filterNum,imageNum) = poolImage(indx,indx);
    end
end

end

