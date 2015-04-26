function [ output ] = getSelective_search( images)
%INITSELECTIVE_SEARCH 此处显示有关此函数的摘要
%   此处显示详细说明
    addpath('selective_search\SelectiveSearchCodeIJCV\Dependencies');
    addpath('selective_search\SelectiveSearchCodeIJCV\');
    % Compile anisotropic gaussian filter
    if(~exist('anigauss'))
        fprintf('Compiling the anisotropic gauss filtering of:\n');
        fprintf('   J. Geusebroek, A. Smeulders, and J. van de Weijer\n');
        fprintf('   Fast anisotropic gauss filtering\n');
        fprintf('   IEEE Transactions on Image Processing, 2003\n');
        fprintf('Source code/Project page:\n');
        fprintf('   http://staff.science.uva.nl/~mark/downloads.html#anigauss\n\n');
        mex Dependencies/anigaussm/anigauss_mex.c Dependencies/anigaussm/anigauss.c -output anigauss
    end
    if(~exist('mexCountWordsIndex'))
        mex Dependencies/mexCountWordsIndex.cpp
    end
    % Compile the code of Felzenszwalb and Huttenlocher, IJCV 2004.
    if(~exist('mexFelzenSegmentIndex'))
        fprintf('Compiling the segmentation algorithm of:\n');
        fprintf('   P. Felzenszwalb and D. Huttenlocher\n');
        fprintf('   Efficient Graph-Based Image Segmentation\n');
        fprintf('   International Journal of Computer Vision, 2004\n');
        fprintf('Source code/Project page:\n');
        fprintf('   http://www.cs.brown.edu/~pff/segment/\n');
        fprintf('Note: A small Matlab wrapper was made.\n');
        %     fprintf('
        mex Dependencies/FelzenSegment/mexFelzenSegmentIndex.cpp -output mexFelzenSegmentIndex;
    end
%%
% Parameters. Note that this controls the number of hierarchical
% segmentations which are combined.
colorTypes = {'Hsv', 'Lab', 'RGI', 'H', 'Intensity'};
colorType = colorTypes{3};                                  % Single color space for demo
% Here you specify which similarity functions to use in merging
simFunctionHandles = {@SSSimColourTextureSizeFillOrig, @SSSimTextureSizeFill, @SSSimBoxFillOrig, @SSSimSize};
simFunctionHandles = simFunctionHandles(3); % Two different merging strategies

% Thresholds for the Felzenszwalb and Huttenlocher segmentation algorithm.
% Note that by default, we set minSize = k, and sigma = 0.8.
k = 80; % controls size of segments of initial segmentation. 
minSize = k;
sigma = 0.8;

m = size(images,3);
for i =1:m
    im = images(:,:,i);
    % Perform Selective Search
    [boxes blobIndIm blobBoxes hierarchy] = Image2HierarchicalGrouping(im, sigma, k, minSize, colorType, simFunctionHandles);
    boxes = BoxRemoveDuplicates(boxes);
    output{i} = boxes;
%    %show all candidate region in one picture. 
%     imshow(im);    
%     for j = 1: size(boxes,1);
%             rectangle('Position',[boxes(j,2), boxes(j,1),boxes(j,3) - boxes(j,1),boxes(j,4)-boxes(j,2)],'edgecolor','g');
%     end
end

end

