function [   ] = t_test(   )
%T_TEST 

im = imread('test2.jpg');
[width ,height] = size(im);
fprintf('width:%d , height:%d\n',width,height);
im = imresize(im,[32,32]);
imshow(im);

end

