function [ loc ] = get_unfixROI( data )
%GET_UNFIXROI 此处显示有关此函数的摘要
%   set 4 point and return unfix rectangle
m = size(data,3);
loc = zeros(4,2,m);  % get 4 point 
for i = 1:m
   imshow(data(:,:,i),[]);
   if ( i<10)        
       [x,y] = ginput(4);
       loc(:,:,i) =  [x(:),y(:)];
       disp([x,y]);      
       % draw the rectangle 
       rectangle('Position',[loc(1,:,i),loc(2,:,i)-loc(1,:,i)],'edgecolor','r');
       rectangle('Position',[loc(3,:,i),loc(4,:,i)-loc(3,:,i)],'edgecolor','r');
       hold on 
       % draw central point 
       % certain magnitude rectangle get fix-size input 
       center1 = (loc(1,:,i)+1/2.*(loc(2,:,i)-loc(1,:,i)));
       center2 = (loc(3,:,i)+1/2.*(loc(4,:,i)-loc(3,:,i)));
       plot(center1(1),center1(2), 'g*')
       plot(center2(1),center2(2), 'r*')
       pause();       
   end
   save('loc.mat','loc');
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%        this is for best region   
%        lc(i).p1 = [x(1),y(1),x(2)-x(1),y(2)-y(1)];  % x,y ,width,height
%        lc(i).p1c = [x(1)+1/2*(x(2)-x(1)),y1(1)+1/2*(y(2)-y(1))];
%        lc(i).p2 = [x(3),y(3),x(4)-x(3),y(4)-y(3)];
%        lc(i).p2c = [x(3)+1/2*(x(4)-x(3)),y(3)+1/2*(y(4)-y(3))];

end

