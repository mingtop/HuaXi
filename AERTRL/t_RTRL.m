%% AE + RTRL 
%  I(t) denote targets at time(t) , predict output at t+4.
%  Problems about prediction
clc ; clear ; close all
relu = @(x) max(0,x);
gradRelu = @(x) max(0,x)>1;           % relu
sigmoid = @(x) 1./(1+exp(-x));
gradSigmoid = @(x) sigmoid(x).*(1-sigmoid(x));

%%  init autoencoder
net_AE.layer = [28*28,100,28*28];
for i = 1:length(net_AE.layer)-1
    net_AE.w{i} =  2*(rand(net_AE.layer(i+1),net_AE.layer(i))-0.5)./sqrt(net_AE.layer(i+1)+net_AE.layer(i))-1;
    net_AE.b{i} = zeros(net_AE.layer(i+1),1);
end
net_AE.opt.alpha = 0.01;
net_AE.opt.batchSize = 128;
net_AE.opt.epoches = 100;
net_AE.opt.momentum = 0.9;
%load data
addpath ../data/mnist/
trainData = loadMNISTImages('train-images.idx3-ubyte');
trainLabels = loadMNISTLabels('train-labels.idx1-ubyte');
% net_AE = minFuncSGD(net_AE,trainData);
% save ( 'net_AE.mat','net_AE');
load net_AE ;

%% RTRL
% pre-data
I1 = find((trainLabels==1)==1);
I2 = find((trainLabels==2)==1);
% I = [I1;I2];
I = I1;

[x,d,input,zd] = getData(net_AE,I,trainData);
delay.input{1} = input;         % x{i} is a scaler
delay.z{1} = zd;        % z{i} maybe a vector
alpha =1e-4;
n = length(d);                                                % dim_y
m = net_AE.layer(2);                                          % dim_external_x
p = zeros(n,n*(m+n));

timeDelay = 3;                                                 % note the real delay
d_delay = zeros(n,timeDelay);
d_delay(:,end) = d;

isBP = true;
%  Backpropagation  BP
thetay = zeros( n ,timeDelay);
thetax = zeros( m ,timeDelay);
%% train
y = zeros(n,1);
z = [y;x];
w = 1e-1*((-2)*rand(n,m+n)+1);
s = w*z;
y = relu(s);                            % t = 1

for i = 1:timeDelay-2
    
    [x,d,input,zd] = getData(net_AE,I,trainData);
    delay.input{i+1} = input;
    delay.z{i+1} = zd;                            % first z{1} is set at beginning
    % handle - d
    for j=1:size(d_delay,2)-1
        d_delay(:,j) = d_delay(:,j+1);
    end
    d_delay(:,end) = d;
    
    z = [y;x];
    s = w*z;
    y = relu(s);
    
end

maxIter = 1000000;
error = [ ];
debug = false;

for it = 1:maxIter
    
    [x,d,input,zd] = getData(net_AE,I,trainData);
    delay.z{timeDelay} = zd;          % every time get lastest z
    delay.input{timeDelay} = input;
    % handle - d's delay
    for j=1:size(d_delay,2)-1
        d_delay(:,j) = d_delay(:,j+1);
    end
    d_delay(:,end) = d;
    if debug
        imshow(reshape(d,7,7),[]);
        pause();
    end
    z = [y;x];
    s = w*z;
    y = relu(s);
    % RTRL updata
    cell_z = repmat( num2cell(z',2), n , 1);
    delta_p = w(:,1:n)*p + blkdiag(cell_z{:});
    delta_p = bsxfun(@times, delta_p , gradRelu(s));
    err = d_delay(:,1) - y;
    delta_y = err;
    grad_w = delta_y'*delta_p;
    grad_w = reshape(grad_w,size(w'));                  % Notes: w'
    w = w + alpha*grad_w';
    
    %FF BP update
    if isBP
        theta = -err;
        for i = timeDelay : -1 :1
            if i == timeDelay
                theta = w'*theta;                    % theta x
            else
                theta = w'*thetay(:,i+1);
            end
            thetay(:,i) = theta(1:n);
            thetax(:,i) = theta(n+1:end);
        end
        
        % update thetax every ticks
        for i = 1:timeDelay
            net_AE = AE_update(net_AE,thetax,delay);
        end
        
        % handle z
        for i = 1:timeDelay-1
            delay.z{i+1} = delay.z{i};
            delay.input{i+1} = delay.input{i};
        end
    end
    
    error = [error,1/2.*sum(err.^2)];
    
    if mod(it ,50) == 0
        h3 = plot(error);
        fprintf('it:%d  err:%f\n',it,1/2.*sum(err.^2));
        pause(0.001);
    end
    
    if mod( it ,20000) == 0
        str1 = sprintf('rtrl%d.mat',it);
        save(str1,'w');
    end
end;
save('rtrl.mat','w');
load rtrl
print -djpeg rtrl_errors.jpg

%%  test
y = zeros(n,1);
[x,d] = getData(net_AE,I,trainData);
z = [y;x];
w = 1e-1*rand(n,m+n) ;
s = w*z;
y = sigmoid(s);                            % t = 1
for j=1:size(d_delay,2)-1
    d_delay(:,j) = d_delay(:,j+1);
end
d_delay(:,end) = d;
for i = 1:timeDelay-2
    
    [x,d] = getData(net_AE,I,trainData);
    % handle - d
    for j=1:size(d_delay,2)-1
        d_delay(:,j) = d_delay(:,j+1);
    end
    d_delay(:,end) = d;
    
    z = [y;x];
    s = w*z;
    y = sigmoid(s);
    
end
testIter = 100;
figure
for it = 1:testIter
    
    [x,d] = getData(net_AE,I,trainData);
    
    for j=1:size(d_delay,2)-1
        d_delay(:,j) = d_delay(:,j+1);
    end
    d_delay(:,end) = d;
    
    z = [y;x];
    s = w*z;
    y = sigmoid(s);
        level = graythresh(y);
        y = im2bw(y,level);
    imshow(reshape(y,fix(sqrt(n)),fix(sqrt(n))),[]);
    pause();
end
