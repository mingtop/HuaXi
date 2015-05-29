% function [  ] = preData2Map( inputpath )
function [  ] = preData2Map( )
% get the data and learned the map
%   inputpath = 'D:\HuaXiData\Jawbone'
%   caseName  =  'cd1'
%   jpgName = '.jpg'
inputpath = 'D:\HuaXiData\Jawbone';
addpath(inputpath);
filePath = dir(inputpath); % filePath = dir('');
n = length(filePath);
caseNum = n -2;          % except ./ ../
caseName = cell(caseNum,1);
j = 1;
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% path structure 
%     D:\HuaXiData\Jawbone\cd1\JPG
%     D:\HuaXiData\Jawbone\cd1\DICOM
%     D:\HuaXiData\Jawbone\cd1\MASK
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

for i = 1:n
    % directory     ./ ../ ./cd1 ./cd2µÈ
    if filePath(i).isdir == 1  && ~strcmp(filePath(i).name,'.') && ~strcmp(filePath(i).name,'..')   
        caseName{j} = filePath(i).name;
        j = j+1;
    end
end

% get  ////// JPG  //////    file from different folders
% save ///// MASK //////

% label path   also saved in jpgCell maskCell
fjpg = fopen('jpg.txt','w+');
fmask = fopen('mask.txt','w+');
indxNum = 0;   % for index 

for i = 1:length(caseName)
   % names of paths
   casepath = sprintf('%s\\%s',inputpath,caseName{i});
   jpgpath = sprintf('%s\\JPG',casepath);
   maskpath = sprintf('%s\\MASK',casepath);
   %DIRS the /cd{i}/JPG/*
   jpgdir = dir(jpgpath);   
   num = length(jpgdir);
   jpgNum = num - 2;
   jpgName = cell(jpgNum,1);
   % Traverse the images
   k = 1;      % to store the k_indx
   for j = 1: num
       indxNum = indxNum + 1;
       % trav
       if jpgdir(j).isdir == 0
           tName = jpgdir(j).name;
           jpgName{k} =  tName ;           
           
           tfullName = sprintf('%s\\%s\n',jpgpath,tName);
           maskfullName = sprintf('%s\\%s\n',maskpath,tName);
           fprintf(fjpg,'%s',tfullName);
           fprintf(fmask,'%s',maskfullName);
           
           jpgCell{indxNum}  =  tfullName;
           maskCell{indxNum} =  maskfullName;
           
           mask = getMask(tfullName);
           imwrite(mask,maskfullName);
           
           % show results
           subplot(1,2,1);
           im = imread(tfullName);
           imshow(im,[]);
           subplot(1,2,2);
           imshow(mask,[]);
           pause(0.01);
           k = k+1;
       end
       
   end
   
   disp(casepath);
   
end
fclose(fjpg);
fclose(fmask);

save('jpgLabel',jpgCell);
save('maskLabel',maskCell);

end

