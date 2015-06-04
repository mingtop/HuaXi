% function [  ] = loadData( inputpath  )
% 1. Because the BigData 
% 2. 
% 3. 
inputpath = 'D:\HuaXiData\Jawbone\train';
addpath(inputpath);
filePath = dir(inputpath); % filePath = dir('');
n = length(filePath);
caseNum = n -2;          % except ./ ../
caseName = cell(caseNum,1);
j = 1;
% get cases 
for i = 1:n
    % directory     ./ ../ ./cd1 ./cd2µÈ
    if filePath(i).isdir == 1  && ~strcmp(filePath(i).name,'.') && ~strcmp(filePath(i).name,'..')   
        caseName{j} = filePath(i).name;
        j = j+1;
    end
end

% 2. get total number's of train-set
totalNum = 0;
% travels each cases 
for i = 1:length(caseName)
   % names of paths
   casepath = sprintf('%s\\%s',inputpath,caseName{i});
   jpgpath = sprintf('%s\\DICOM',casepath);
   maskpath = sprintf('%s\\MASK',casepath);
   %DIRS the /cd{i}/JPG/*
   jpgdir = dir(jpgpath);   
   jpgnum = length(jpgdir);
   totalNum = totalNum + jpgnum - 2;  % ./ ./   
end
% totalNum = 36596

% 3. load image 
% only load imgData needs 20G    256*256*3*40000
imgWidth   = 256;
imgHeight  = 256;
maskWidth  = 64;
maskHeight = 64;
imageData = zeros(imgWidth,imgHeight,totalNum); 
maskData =  zeros(maskWidth,maskHeight,totalNum);
indexNum = 0;
for i = 1:length(caseName)
    % names of paths
   casepath = sprintf('%s\\%s',inputpath,caseName{i});
   jpgpath = sprintf('%s\\DICOM',casepath);
   maskpath = sprintf('%s\\MASK',casepath);
   %DIRS the /cd{i}/JPG/*
   jpgdir = dir(jpgpath);   
   num = length(jpgdir);
   jpgNum = num - 2;
   % Traverse the images   
   for j = 1: num
       % trav
       if jpgdir(j).isdir == 0
           indexNum = indexNum + 1;
           tName = jpgdir(j).name;
           tfullName = sprintf('%s\\%s\n',jpgpath,tName);           
           maskfullName = sprintf('%s\\%s\n',maskpath,tName);
           im1 = imread(tfullName);
           im2 = imread(maskfullName);
           im1 = rgb2gray(im1);
           im1 = imresize(im1,[imgWidth, imgHeight]);
           im2 = imresize(im2,[maskWidth,maskHeight]);
           imageData(:,:,indexNum) = im1;
           maskData(:,:,indexNum) = im2;
           if mod( indexNum ,500) == 1
               disp(indexNum);
           end;
       end
   end
    
end

% end

