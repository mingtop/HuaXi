function [ data ] = loadData( inputpath )
%load data and convert to gray
    addpath(inputpath);
    filePath = dir(inputpath); % filePath = dir('E:\HuaXiData\sampleData\YU ZHANG LI');
    n = length(filePath);
    fileNum = n -2;
    c = cell(fileNum,1);
    j = 1;
    for i = 1:n
        if filePath(i).isdir == 0
            if j == 1
                c{j} = filePath(i).name;
                im = rgb2gray(imread(char(c{j})));
                data = zeros(size(im,1),size(im,2),fileNum);
                data(:,:,j) = im;
                j = j+1;
            else
                c{j} = filePath(i).name;
                data(:,:,j) = rgb2gray(imread(char(c{j})));
                j = j+1;
            end
        end
    end  
end

