% function [  ] = checkData(  )
%CHECKDATA 
% 1. check the train-number has the same number with mask-number in same case!
% 2. statistic the widths/heights  
% 3. 
% 4. 
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

% indxNum = 0;   % for index 
% 2. inital the number's of width(1) and height(2)
imgSize = zeros(2,caseNum);

% travels each cases 
for i = 1:length(caseName)
   % names of paths
   casepath = sprintf('%s\\%s',inputpath,caseName{i});
   jpgpath = sprintf('%s\\JPG',casepath);
   maskpath = sprintf('%s\\MASK',casepath);
   %DIRS the /cd{i}/JPG/*
   jpgdir = dir(jpgpath);   
   jpgnum = length(jpgdir);
   maskdir = dir(maskpath);
   masknum = length(maskdir);
   % 1. jpgNum == maskNum
   if ~( jpgnum == masknum)
       fprintf('case %d : has different numbers!\n ',i);        %  ./ ../
   end
   % 2. statistic the width and heigth 
   
   % Traverse the images
   k = 1;      % to store the k_indx
   for j = 1:3
       if jpgdir(j).isdir == 0  && k == 1
          tName = jpgdir(j).name;          
          tfullName = sprintf('%s\\%s',jpgpath,tName);
          im = imread(tfullName);
          [width ,height,~] = size(im);
          imgSize(1,i) = width;
          imgSize(2,i) = height;
          fprintf('case:%d  width: %d ,  height:%d\n',i,width,height);  
           k = k+1;
       end
   end
end
   disp('end!')
% end

