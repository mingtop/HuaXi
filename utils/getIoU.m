function [ iou ] = getIoU( p1,p2,width,height )
%TESTMEANSURE 
%  compute intersection-over-union by ratio
%  % fix region-windows size  so I only need one width and height
%   params:
%       iou :  the IoU value;
%       p1:  the base location ( left-up point of an rectangle ) [x,y]
%       p2 : is the pixel location to detected                   [x,y]
%       width,height : is p2's window
   iou = -1;
   indx = 0;
   x1 = p1(1);
   y1 = p1(2);
   x2 = p2(1);
   y2 = p2(2);
   if  x1<= x2
       if y1 <= y2 
           indx = 1;
       else
           indx = 2;
       end      
   else 
       if y1 <= y2 
           indx = 4;
       else
           indx = 3;
       end      
   end
%    assert(indx>0,'error in getIoU!');    
   zone1 = width*height;   
   switch indx
       case 1
           x1 = x1 + width;
           y2 = y2 +height;
           zone = (x1-x2).*(y2-y1);
           if (x1-x2)<0 ||(y2-y1)<0
               zone = 0;
           end
       case 2
           x1 = x1 + width;
           y1 = y1 + height;
           zone = (x1-x2).*(y1-y2);
           if (x1-x2)<0 || (y1-y2)<0
               zone =0;
           end
       case 3
           x2 = x2 + width; 
           y1 = y1 + height;
           zone = (x2-x1).*(y1-y2);
           if (x2-x1)<0 || (y1-y2)<0
               zone=0;
           end
       case 4
           x2 = x2 + width;
           y2 = y2 + height;
           zone = (x2-x1).*(y2-y1);
           if (x2-x1)<0 || (y2-y1) <0
               zone = 0;
           end
   end
   if zone <= 0 
       iou = 0;
   else 
       iou = zone./zone1;
   end
%    assert(iou<0,'getIoU.m runs error!');

end

