%% 1.init  
disp('1. init network');
addpath utils 
addpath results
addpath selective_search   % get proposal rectangle

width = 50;       % kernel size 
height = 50;     
DEBUG = false;    %show the rectangle in sample Data;
isDICOM = true;
sampleNum = 10;   % the number of sample - need draw fracture origion!
unlabelNum = 5000;
posNum = 400;
negNum = 400;

%% 2. Get Data
disp('2. load data');
h = tic;
% data = loadDIData('D:\HuaXiData\DICOM\YUZHANGLI\S44560\S20');  % total dataset
data = loadDIData('D:\HuaXiData\sampleData\DICOM');          % just fracture data
fprintf('load orgin dicom data takes %f sconds.\n',toc(h));
%% 3.1 Set fracture region by hand -- FIX fracture region
disp('3. set fracture region by draw  rectangle');
% fracture region detection
%     fr = get_fixRegion(data,sampleNum);       
%     save('./results/fr.mat','fr');
    load fr                                       % fr is a cell
    
%% 4. Sample fracture data and negative region data
th = tic;
disp('4.1 get unlabel fix rectangle data');
uwidth =5;
uheight =5;
data_unlabel = sampleUNdata('D:\HuaXiData\sampleData\DICOM',uwidth,uheight,unlabelNum,isDICOM,DEBUG);  %set a path
if ~isDICOM  % DICOM data range in [ 0 - 1 ] 
    data_unlabel = normalizeData(data_unlabel); 
end

disp('4.2 get negtive fix rectangle data ');
[dataNP,labelNP] = sampleNPdata3(data,fr,width,height,posNum,negNum,DEBUG);
if ~isDICOM
    dataNP = normalizeData(dataNP);  
end
fprintf('* Data processed done in %3f seconds\n',toc(th)); 
close ;

%% 5. Train autoencoder  -----for initial CNN
% check gradient
disp('5. train the autoencoder ');
inputSize = size(data_unlabel,1)*size(data_unlabel,2);
hiddenSize = 10;
theta = initAEParams(inputSize,hiddenSize);
opt.epoches = 200;
opt.batchSize = 256;
opt.alpha = 0.02;
opt.momentum = 0.90;
opt.threshold = 1e-6;
optthetaAE = minFuncSGD(@(x,y)AEcost(x,y,inputSize,hiddenSize),theta,data_unlabel,opt);
save ( './results/optthetaAE_cnn.mat','optthetaAE');
load ./results/optthetaAE_cnn ;

figure ; 
% optthetaAE = theta;
W1 = reshape(optthetaAE(1:hiddenSize*inputSize), hiddenSize, inputSize);
display_network(W1', 12); 
print -djpeg ./results/W1_cnn_weights.jpg   

%% 6. Fine-tune a binary classification     ¡¢
disp('6. Fine-tune CNN');
opt.epochs = 30;
opt.minibatch = 256;
opt.alpha = 5e-1;
opt.momentum = 0.9;

labelNP(labelNP == 0)=2;    % 1 is positive  2 is negative
% % CNN
imageDim = size(dataNP,1); % 50
numClasses = 2;  % Number of classes 
c1filterDim = 5;    % Filter size for conv layer
c1numFilters = 6;   % Number of filters for conv layer
c3filterDim = 4;
c3numFilters = 6*16;
s2poolDim = 2;      % Pooling dimension, (should divide imageDim-filterDim+1)
s4poolDim = 2;
c5Dim = 120;
c6Dim = 84;
% Initialize Parameters
% theta_cnn = cnnInitParams(imageDim,c1filterDim,c1numFilters,s2poolDim,...
%     c3filterDim,c3numFilters,s4poolDim,c5Dim,c6Dim,numClasses);
theta_cnn = theta;
% theta_cnn(1:hiddenSize*inputSize) = optthetaAE(1:hiddenSize*inputSize);
optthetaF = minFunCNNSGD(@(x,y,z)cnnCost(x,y,z,numClasses,c1filterDim,c1numFilters,c3filterDim,c3numFilters,...
                                s2poolDim,s4poolDim,c5Dim,c6Dim),theta_cnn,dataNP,labelNP,opt);
save ( './results/optthetaF_cnn.mat','optthetaF');                           
load ./results/optthetaF_cnn ;


%% 7. Test 
% Only find candidate region around the first given location
% OR will get wrong result
m = size(data,3);
testData = data(:,:,sampleNum+1:m); 
% testData = data(:,:,m-1:m); 
BoxLoc = preRegionLoc(optthetaF,testData,numClasses,c1filterDim,c1numFilters,c3filterDim,c3numFilters,...
                                s2poolDim,s4poolDim,c5Dim,c6Dim,imageDim,DEBUG);
save('./results/BoxLoc.mat','BoxLoc');

%% farther work 
% 1. change finetune to cnn