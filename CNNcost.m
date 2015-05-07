function [cost, grad, preds] = cnnCost(theta,images,labels,numClasses,...
                                c1filterDim,c1numFilters,c3filterDim,c3numFilters,...
                                s2poolDim,s4poolDim,c5Dim,c6Dim,pred)                                                      
% Calcualte cost and gradient for a single layer convolutional
% neural network followed by a softmax layer with cross entropy
% objective.
%                            
% Parameters:
%  theta      -  unrolled parameter vector
%  images     -  stores images in imageDim x imageDim x numImges
%                array
%  numClasses -  number of classes to                                                                                                    predict
%  filterDim  -  dimension of convolutional filter                            
%  numFilters -  number of convolutional filters
%  poolDim    -  dimension of pooling area
%  pred       -  boolean only forward propagate and return
%                predictions
%
%
% Returns:
%  cost       -  cross entropy cost
%  grad       -  gradient with respect to theta (if pred==False)
%  preds      -  list of predictions for each example (if pred==True)
% 
%
% Note: 
%   ALL pooling layer has no sigmoid function
% 

if ~exist('pred','var')
    pred = false;
    preds = 0;
end;


imageDim = size(images,1); % height/width of image
numImages = size(images,3); % number of images

%% Reshape parameters and setup gradient matrices

% Wc is filterDim x filterDim x numFilters parameter matrix
% bc is the corresponding bias

% Wd is numClasses x hiddenSize parameter matrix where hiddenSize
% is the number of output units from the convolutional layer
% bd is corresponding bias
[Wc1, Wc3, Wc5, Wc6, Wc7, bc1, bc3, bc5, bc6, bc7] = cnnParamsToStack(theta,imageDim,...
                c1filterDim,c1numFilters,c3filterDim,c3numFilters,...
                s2poolDim,s4poolDim,c5Dim,c6Dim,numClasses);
% Same sizes as Wc,Wd,bc,bd. Used to hold gradient w.r.t above params.
Wc1_grad = zeros(size(Wc1));
Wc3_grad = zeros(size(Wc3));
Wc5_grad = zeros(size(Wc5));
Wc6_grad = zeros(size(Wc6));
Wc7_grad = zeros(size(Wc7));
bc1_grad = zeros(size(bc1));
bc3_grad = zeros(size(bc3));
bc5_grad = zeros(size(bc5));
bc6_grad = zeros(size(bc6));
bc7_grad = zeros(size(bc7));

%%======================================================================
%% STEP 1a: Forward Propagation
%  In this step you will forward propagate the input through the
%  convolutional and subsampling (mean pooling) layers.  You will then use
%  the responses from the convolution and pooling layer as the input to a
%  standard softmax layer.

%% Convolutional Layer
%  For each image and each filter, convolve the image with the filter, add
%  the bias and apply the sigmoid nonlinearity.  Then subsample the 
%  convolved activations with mean pooling.  Store the results of the
%  convolution in activations and the results of the pooling in
%  activationsPooled.  You will need to save the convolved activations for
%  backpropagation.
c1convDim = imageDim-c1filterDim+1; % dimension of convolved output
assert( mod(c1convDim,s2poolDim)==0, 'c1Dim can not divided by s2poolDim');
s2outputDim = (c1convDim)/s2poolDim; % dimension of subsampled output

% convDim x convDim x numFilters x numImages tensor for storing activations
% c1activations = zeros(c1convDim,c1convDim,c1numFilters,numImages);

% outputDim x outputDim x numFilters x numImages tensor for storing
% subsampled activat
% s2activationsPooled = zeros(s2outputDim,s2outputDim,c1numFilters,numImages);

%%% YOUR CODE HERE %%%
c1convolvedFeatures = cnnConvolve(c1filterDim,c1numFilters,images,Wc1,bc1);
c1activations = c1convolvedFeatures;               % has add sigmoid in cnnConvolve
s2pooledFeatures = cnnPool(s2poolDim,c1activations);    % not sigmoid function here
s2activationsPooled = s2pooledFeatures;

% s2-c3 is fullconnected network not Lenet-5   here is a convolution 
c3convDim = s2outputDim - c3filterDim + 1;
c3convolvedImage = zeros(c3convDim,c3convDim,c3numFilters,numImages);
c3activations = zeros(c3convDim,c3convDim,c3numFilters/c1numFilters,numImages);
%%%%%%%%%%%%%%%
%             0 1  2  ... 15
%   Wc3 = 0 [ 1 7 13 ... 91
    %     1   2 8 14 ... 92
    %     2   3 ........
    %     .   .......... 95
    %     5   6 12 ..... 96 ]
%%%%%%%%%%%%%
for imageNum =1:numImages
    c1filterNum = 1;    
    c1num =1;
    for c3filterNum = 1:c3numFilters        
        kernel = rot90(Wc3(:,:,c3filterNum),2);
        c3convolvedImage(:,:,c3filterNum,imageNum) = conv2(...
            s2activationsPooled(:,:,c1num,imageNum),kernel,'valid');
        % s2activationsPooled(:,:,c1filterNum,imageNum),kernel,'valid');  %
        % the line before I write wrong!!  because I don't take care of the
        % computation order!!! 
        % We should compute every pooling-feature of S2 
        c1num = c1num+1;
        if mod(c3filterNum,c1numFilters)==0  % sum to one featuremap in c3 layer
            res = sum(c3convolvedImage(:,:, (c3filterNum-c1numFilters +1):c3filterNum,imageNum),3) + bc3(c1filterNum);
            c3activations(:,:,c3filterNum/c1numFilters,imageNum) = 1./(1+exp(-res));
            c1filterNum = c1filterNum + 1;
            c1num = 1;
        end
    end    
end
% s4 c5 c6 c7
assert ( mod(c3convDim,s4poolDim)==0, 's4dim can not divided by s4poolDim');
s4outputDim = c3convDim/s4poolDim;
s4activationsPooled = cnnPool(s4poolDim,c3activations); % no sigmoid here
s4activationsPooled = reshape(s4activationsPooled,[],numImages);
c5activations = bsxfun(@plus,Wc5*s4activationsPooled ,bc5);
c5activations = 1./(1+exp(-c5activations));
c6activations = bsxfun(@plus,Wc6*c5activations,bc6);
c6activations = 1./(1+exp(-c6activations));
% softmax 
s = bsxfun(@plus,Wc7*c6activations,bc7);
s = bsxfun(@minus,s,max(s,[],1));
s = exp(s);
s = bsxfun(@rdivide,s,sum(s));
probs = s;
% logistic regression
    % s = 1./(1+exp(-s));
    % probs =s;

% Makes predictions given probs and returns without backproagating errors.
if pred
        % not return the class but the problity 
        %     [~,preds] = max(probs,[],1);
        %     preds = preds';
    preds = probs;
    grad = 0;
    cost = 0;
    return;
end;
%%======================================================================
%% STEP 1b: Calculate Cost
%  In this step you will use the labels given as input and the probs
%  calculate above to evaluate the cross entropy objective.  Store your
%  results in cost.

cost = 0; % save objective into cost

%%% YOUR CODE HERE %%%

groundTrue = full(sparse(labels,1:numImages,1));
% groundTrue = labels;

cost = -(1./numImages).*sum(sum(groundTrue.*log(probs)));  % only CE here?



%%======================================================================
%% STEP 1c: Backpropagation
%  Backpropagate errors through the softmax and convolutional/subsampling
%  layers.  Store the errors for the next step to calculate the gradient.
%  Backpropagating the error w.r.t the softmax layer is as usual.  To
%  backpropagate through the pooling layer, you will need to upsample the
%  error with respect to the pooling layer for each filter and each image.  
%  Use the kron function and a matrix of ones to do this upsampling 
%  quickly.

%%% YOUR CODE HERE %%%
thetac7 = -(groundTrue-s);
% thetac7 = -(groundTrue -s).*s.*(1-s);
thetac6 = Wc7'*thetac7.*c6activations.*(1-c6activations);  % here the NO order has a lot different! wc7 means wc6 
thetac5 = Wc6'*thetac6.*c5activations.*(1-c5activations);
thetas4 = Wc5'*thetac5;   % here no sigmoid function s4 is a pooling layer
% unroll the theta 
assert(mod(c3numFilters,c1numFilters)==0, 'c3numFilters can not divided by c1numFilters');
c3numtheta = c3numFilters/c1numFilters;   % the theta of c3 is different from c3numFilters
thetas4 = reshape(thetas4,s4outputDim,s4outputDim,c3numtheta,numImages);  % to get kron
thetac3 = zeros(c3convDim,c3convDim,c3numtheta,numImages);
for imageNum =1:numImages
    for c3thetaNum = 1:c3numtheta
        %thetaConvolved(:,:,filterNum,imageNum) = 1./((poolDim).^2).*(kron(thetaPool(:,:,filterNum,imageNum),ones(poolDim)));
        thetac3(:,:,c3thetaNum,imageNum) = 1./((s4poolDim).^2).*(kron(thetas4(:,:,c3thetaNum,imageNum),...
            ones(s4poolDim))).*c3activations(:,:,c3thetaNum,imageNum).*(1-c3activations(:,:,c3thetaNum,imageNum));
    end
end
% handle the full connection between s2-c3
%%%%%%%%%%%%%%%
%             0 1  2  ... 15
%   Wc3 = 0 [ 1 7 13 ... 91
    %     1   2 8 14 ... 92
    %     2   3 ........
    %     .   .......... 95
    %     5   6 12 ..... 96 ]
%%%%%%%%%%%%%
Wc3_ = reshape(Wc3,c3filterDim,c3filterDim,c1numFilters,c3numFilters/c1numFilters);
thetas2 = zeros(s2outputDim,s2outputDim,c1numFilters,numImages);
for imageNum = 1:numImages
    for i = 1:c1numFilters       
        for j = 1:c3numFilters/c1numFilters    % 16 
%            kernel = rot90(Wc3_(:,:,i,j),2);  %here is BP of c3 -> s2
             kernel = Wc3_(:,:,i,j);
            % so do not neet rot180 degree. 
            thetas2(:,:,i,imageNum) = thetas2(:,:,i,imageNum)+...
                conv2(thetac3(:,:,j,imageNum),kernel,'full'); 
            % s2 is pooling layer, so do not grad_F.
        end
    end
end
% (1/c1numFilters) I added in my opion   It's wrong when I added
% thetas2 = (1/c1numFilters).*thetas2;  % thetac3 is combin of s2numFilters(c1numFilters);
% spooling to convolution s2 -> c1 
thetac1 = zeros(c1convDim,c1convDim,c1numFilters,numImages);
for imageNum =1:numImages
    for c1filterNum = 1:c1numFilters
        %thetaConvolved(:,:,filterNum,imageNum) = 1./((poolDim).^2).*(kron(thetaPool(:,:,filterNum,imageNum),ones(poolDim)));
        thetac1(:,:,c1filterNum,imageNum) = 1./((s2poolDim).^2).*(kron(thetas2(:,:,c1filterNum,imageNum),...
            ones(s2poolDim))).*c1activations(:,:,c1filterNum,imageNum).*(1-c1activations(:,:,c1filterNum,imageNum));
    end
end

%%======================================================================
%% STEP 1d: Gradient Calculation
%  After backpropagating the errors above, we can use them to calculate the
%  gradient with respect to all the parameters.  The gradient w.r.t the
%  softmax layer is calculated as usual.  To calculate the gradient w.r.t.
%  a filter in the convolutional layer, convolve the backpropagated error
%  for that filter with each image and aggregate over images.

%%% YOUR CODE HERE %%%
m = numImages;
Wc7_grad = 1./m*(thetac7*c6activations');
bc7_grad = 1./m*(sum(thetac7,2));
Wc6_grad = 1./m*(thetac6*c5activations');
bc6_grad = 1./m*(sum(thetac6,2));
Wc5_grad = 1./m*(thetac5*s4activationsPooled');
bc5_grad = 1./m*(sum(thetac5,2));

Wc3_grad_t = zeros([size(Wc3_grad),numImages]);
% bc_grad_t = zeros(size(bc_grad),
for imageNum = 1:numImages
    for indx = 1:c1numFilters      %  6
        for indy = 1:c3numFilters/c1numFilters  % 16
%             kernel = rot90(squeeze(thetac3(:,:,indy,imageNum)),2);
            kernel = rot90(thetac3(:,:,indy,imageNum),2);
            Wc3_grad_t(:,:,(indy-1)*c1numFilters+indx,imageNum) = conv2(s2activationsPooled(:,:,indx,imageNum),kernel,'valid');
        end  % this step has no error, I take code wrong in my step of computation of C3 in feedforward step
    end
end
Wc3_grad = (1./m).*sum(Wc3_grad_t,4);   
bc3_grad = (1./m).*squeeze(sum(sum(sum(thetac3,4),1),2));  % here !
% Wc1_grad
Wc1_grad_t = zeros([size(Wc1_grad),numImages]);
for imageNum = 1:numImages
    for filterNum = 1:c1numFilters    
        kernel = rot90(thetac1(:,:,filterNum,imageNum),2);
        Wc1_grad_t(:,:,filterNum,imageNum) = conv2(images(:,:,imageNum),kernel,'valid');
    end
end
Wc1_grad = (1./m).*sum(Wc1_grad_t,4);   
bc1_grad = (1./m).*squeeze(sum(sum(sum(thetac1,4),1),2));

%% Unroll gradient into grad vector for minFunc
grad = [Wc1_grad(:) ; Wc3_grad(:); Wc5_grad(:); Wc6_grad(:); Wc7_grad(:);...
    bc1_grad(:); bc3_grad(:) ; bc5_grad(:); bc6_grad(:); bc7_grad(:)];

end
