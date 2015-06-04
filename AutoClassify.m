%% 1.init  
disp('1. init network');
addpath utils 
addpath results

width = 25;
height = 64;
DEBUG = false;   %show the rectangle in sample Data;
sampleNum = 10;  % the number of sample - need draw fracture origion!
unlabelNum = 1000;
posNum = 400;
negNum = 400;

%% 2. Get Data
disp('2. load data');
h = tic;
% data = loadDIData('D:\HuaXiData\DICOM\YUZHANGLI\S44560\S20');
% data = loadDIData('D:\HuaXiData\sampleData\DICOM');
data = loadData('D:\HuaXiData\sampleData\YU ZHANG LI');
fprintf('load orgin data takes %f sconds.\n',toc(h));
%% 3.1 Set fracture region by hand -- FIX fracture region
disp('3. set fix rectangle by 2 central points');

% fracture detection    
lc = get_fixROI(data,sampleNum,width,height); 
% save('./results/lc.mat','lc');
load ./results/lc
    
%% 4. Sample fracture data and negative region data
th = tic;
disp('4.1 get unlabel fix rectangle data');
data_unlabel = sampleUNdata('D:\HuaXiData\sampleData\YU ZHANG LI',width,height,unlabelNum,DEBUG); %set a path
data_unlabel = normalizeData(data_unlabel);
% 4.1 can load data on  E:\HuaXiData\sampleData\mat_YUZHANGLI\data_unlabel25-64.mat
disp('4.2 get negtive fix rectangle data ');
[dataNP,labelNP] = sampleNPdata2(data,lc,width,height,posNum,negNum,DEBUG);
dataNP = normalizeData(dataNP); 
fprintf('* Data processed done in %d seconds\n',toc(th)); 
close;

%% 5. Train autoencoder  ----- later replace by CNN
% check gradient
disp('5. train the autoencoder ');
if DEBUG 
    inputSize = 100;
    hiddenSize = 20;
    t_data = data_unlabel(1:25,1:4,1:10);    
    theta = initAEParams(inputSize,hiddenSize);    
    [cost, grad]= AEcost(theta,t_data,inputSize,hiddenSize);    
    numgrad = checkNumgrad(@(x)AEcost(x,t_data,inputSize,hiddenSize),theta);
    
    disp([grad,numgrad]);    
    diff = norm(numgrad-grad)/norm(numgrad+grad);
    disp(diff);    
%     save ('./results/grad.mat','grad','numgrad');   % v1.0 check 
end
inputSize = size(data_unlabel,1)*size(data_unlabel,2);
hiddenSize = 100;
theta = initAEParams(inputSize,hiddenSize);
opt.epoches = 100;
opt.batchSize = 256;
opt.alpha = 0.2;
opt.momentum = 0.9;
opt.threshold = 1e-6;
% optthetaAE = miniFuncSGD(@(x,y)AEcost(x,y,inputSize,hiddenSize),theta,data_unlabel,opt);
% save ( './results/optthetaAE.mat','optthetaAE');
load ./results/optthetaAE ;

figure ; % figure 2;
W1 = reshape(optthetaAE(1:hiddenSize*inputSize), hiddenSize, inputSize);
display_network(W1', 12); 
print -djpeg ./results/W1_weights.jpg   % save the visualization to a file 



%% 6. Fine-tune a binary classification      
opt.epoches = 20;
opt.batchSize = 256;
opt.alpha = 2e-1;
opt.momentum = 0.9;
opt.threshold =  1e-6;

% encode dataNP label
m = size(labelNP,1);
X = [1,0;              % 1 -> 0    0 -> 1
     0,1];             % 0         1
NP=@(x)(X(:,x+1));
label = zeros(2,m);
for i = 1:m
    label(:,i) = NP(labelNP(m));
end

% reason of 2 class instead of 1 is that£º Just compare the largest prossible can get the sample belone to which class. But still need
% threshold.
if DEBUG 
    inputSize = 100;
    hiddenSize = 20;
    classNum = 2;
    t_data = dataNP(1:25,1:4,1:10); 
    t_label = label(:,1:10);
    theta = initAEFParam(optthetaAE,classNum,inputSize,hiddenSize);
    [cost, grad]= AEFcost(theta,t_data,t_label,inputSize,hiddenSize,classNum);    
    numgrad = checkNumgrad(@(x)AEFcost(x,t_data,t_label,inputSize,hiddenSize,classNum),theta);
    disp([grad,numgrad]);    
    diff = norm(numgrad-grad)/norm(numgrad+grad);
    disp(diff);    
%   save ('./results/grad.mat','grad','numgrad');   % v1.0 check 
end

inputSize = size(dataNP,1)*size(dataNP,2);
hiddenSize = 100;
classNum = 2;
optthetaF = initAEFParam(optthetaAE,classNum,inputSize,hiddenSize);
optthetaF = miniFunFSGD(@(x,y,z)AEFcost(x,y,z,inputSize,hiddenSize,classNum),optthetaF,dataNP,label,opt);
save ( './results/optthetaF.mat','optthetaF');
load ./results/optthetaF ;

%% 7. Test 
% Only find candidate region around the first given location
% OR will get wrong result
m = size(data,3);
testData = data(:,:,sampleNum+1:m); 
BoxLoc = preRandLoc(optthetaF,testData,lc,width,height,inputSize,hiddenSize,classNum,DEBUG);
save('./results/BoxLoc.mat','BoxLoc');

%% farther work 
% 1. change finetune to cnn