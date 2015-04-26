function [ data_unlabel ] = sampleUNdata( inputpath,width,height,sampleNum,isDICOM )
% evey pictrue get sampleNum rectangle regions --> to train AutoEncoders
% Just sample data --> no matter the data is pos or neg
% param: 
%   sampleNum : 1000 
%   width,height : the fix region
%   i : the number of files
%   j : the number of DICOM
% I get some regression region of sample region 
warning off all
addpath(inputpath);
filePath = dir(inputpath);       
n = length(filePath);
fileNum = n -2;
c = cell(fileNum,1);
j = 1;
data_unlabel = zeros(height,width,fileNum*sampleNum);
for i = 1:n
    if filePath(i).isdir == 0
        c{j} = filePath(i).name;
        
%         maxX = size(im,1);
%         maxY = size(im,2);
%         x = randi([1,maxX-height],sampleNum,1);
%         y = randi([1,maxY-width],sampleNum,1);

    if isDICOM              %DICOM more large than only do fracture
%         minX = 36;          % all image 
%         minY = 58;
%         maxX = 487;
%         maxY = 512;
        minX = 84;           % certain origen
        minY = 102;
        maxX = 395;
        maxY = 447;
        im = dicomread(char(c{j}));
        if isempty(im)
            continue;
        end
       im = mat2gray(im);   
    else                   % jpg
        minX = 84;
        minY = 102;
        maxX = 395;
        maxY = 447;
        im = rgb2gray(imread(char(c{j})));
    end;
        x = randi([minX,maxX-width],sampleNum,1);
        y = randi([minY,maxY-height],sampleNum,1);
        for sn = 1:sampleNum
            data_unlabel(:,:,(j-1)*sampleNum+sn) = im(x(sn):x(sn)+height-1,y(sn):y(sn)+width-1);
        end     
        j = j+1;
    end
end

end

