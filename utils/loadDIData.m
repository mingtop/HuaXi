function [ data ] = loadData( inputpath )
%load data and convert to gray
% data scale to [0-1 ]  
    addpath(inputpath);
    filePath = dir(inputpath); % filePath = dir('E:\HuaXiData\sampleData\YU ZHANG LI');
    n = length(filePath);
    fileNum = n -3;              % except  ./  ../  DIRFE
    c = cell(fileNum,1);
    j = 1;
    for i = 1:n
        if filePath(i).isdir == 0
            if j == 1
                c{j} = filePath(i).name;
                im = dicomread(char(c{j}));
%                 ratio = 256 /double(max(max(im)));
%                 im = im *ratio;
                if isempty(im)
                    continue;
                end
                im = mat2gray(im);       % scale to [0-1 ]   
                data = zeros(size(im,1),size(im,2),fileNum);
                data(:,:,j) = im;
                j = j+1;
            else
                c{j} = filePath(i).name;
                im = dicomread(char(c{j}));
                data(:,:,j) = mat2gray(im);
                j = j+1;
            end
        end
    end  
end

