function [ BW ] = getMask( input )
%GETMASK 此处显示有关此函数的摘要
%   此处显示详细说明
 
% % im = imread('test3.jpg');
% im = imread(input);
% im = rgb2gray(im);
% % im(end-50:end,end-80:end,:)= 0;
% % gim = im(:,:,2);
% % mask = find(gim)>100;
% % reshape(mask,size(gim));
% level = graythresh(im);
% im = im2bw(im,level);
% % imshow(im);

% using color space
% gim = colorThresholder(im);
RGB = imread(input);
% remove the numbers
RGB(end-50:end,end-80:end,:)= 0;

% Convert RGB image to chosen color space
I = rgb2hsv(RGB);

% Define thresholds for channel 1 based on histogram settings
channel1Min = 0.177;
channel1Max = 0.395;

% Define thresholds for channel 2 based on histogram settings
channel2Min = 0.000;
channel2Max = 1.000;

% Define thresholds for channel 3 based on histogram settings
channel3Min = 0.000;
channel3Max = 0.995;

% Create mask based on chosen histogram thresholds
BW = (I(:,:,1) >= channel1Min ) & (I(:,:,1) <= channel1Max) & ...
    (I(:,:,2) >= channel2Min ) & (I(:,:,2) <= channel2Max) & ...
    (I(:,:,3) >= channel3Min ) & (I(:,:,3) <= channel3Max);

% Initialize output masked image based on input image.
maskedRGBImage = RGB;

% Set background pixels where BW is false to zero.
maskedRGBImage(repmat(~BW,[1 1 3])) = 0;

% subplot(1,2,1);
% imshow(BW,[]);
% subplot(1,2,2);
% maybe don't need this morphological 
BW = bwmorph(BW,'open');
% imshow(BW);

end

