function [ lc ] = get_fixROI( data,num,width,height )
%GETPOSITIVE  Get two click points of windows from DICOM 
% only get two central point by fix region
% params: 
%   num : number to set the 2 central points
%   width ,height is the rectangle windows size 
% returns:
%   lc : a struct of point position and central-points 
m = size(data,3);
wnd = [width,height];       % 25,60region's windowSize   [width , length]
for i = 1:m
    imshow(data(:,:,i),[]);
    if i<num
        [x,y] = ginput(2);
        lc(i).p1c = [x(1),y(1)];
        lc(i).p1 = [x(1)-1/2*wnd(1),y(1)-1/2*wnd(2)];
        lc(i).p2c = [x(2),y(2)];
        lc(i).p2 = [x(2)-1/2*wnd(1),y(2)-1/2*wnd(2)];
        % draw the rectangle
        rectangle('Position',[lc(i).p1,wnd],'edgecolor','r');
        rectangle('Position',[lc(i).p2,wnd],'edgecolor','r');
        hold on
        % draw central point
        plot(lc(i).p1c(1),lc(i).p1c(2), 'g*')
        plot(lc(i).p2c(1),lc(i).p2c(2), 'g*')
        pause();
    end
    
end

end

