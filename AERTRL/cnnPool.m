function pooledFeatures = cnnPool(poolDim, convolvedFeatures)
pooledFeatures = zeros(1/poolDim*size(convolvedFeatures));
% poolImage = zeros(convolvedDim-poolDim+1,convolvedDim-poolDim+1);
filter = (1/poolDim.^2)*ones(poolDim);
poolImage = conv2(convolvedFeatures,filter,'valid');
indx = 1:size(convolvedFeatures,1);
indx = find(mod(indx,poolDim)==0);         % find the indx 
indx = bsxfun(@minus,indx,poolDim-1);      % get the right indx   % NOTE: here is importante   
pooledFeatures(:,:) = poolImage(indx,indx);
end

