function [ data, label ] = sampleNPdata3( orgdata,fr,width,height,posNum,negNum,iShow )
% Arround every central poin get: posNum-positive VS negNum-negtive fix-regions 
% params: 
%       lc : the labeled regions position 
%       posNum,negNum :the numbers of pos/neg region
%       iShow : show the sample rectangle in picture
% return: 
%       data: contains all pos/neg region data
%       labels: every data's labels 
% NOTE:  the distance to central is different for differ case! 
% NOTE:  not conside the exceed boundary condition

% Version 2: 
%     1. In  sampleNPdata2.m I set IoU < 0.5 is a negative sample. In this way,
% the negative sample are more wide than last version.
%        half by half 
%     2. The positive sample keep the same way like last version.

% Version 3:
%   fr: change lc to fr
%   Region detection more sensitive to the aire 


warning off all
sampleNum = length(fr);    
m = sampleNum*(posNum+negNum);
data = zeros(height,width,m);
label = zeros(m,1);
alpha = 1/8;
beta = 1/8;

for i = 1:sampleNum 
  % positive 
  x = randi(fix(alpha*[-width,width]),posNum,1);
  y = randi(fix(beta*[-height,height]),posNum,1);
  im = orgdata(:,:,i);
  point1 = cell2mat(fr{i}.p1);
  point2 = cell2mat(fr{i}.p2);
    offset = abs(point1-point2);         % and dimensions
  idx = bsxfun(@plus,x, point1(1));
  idy = bsxfun(@plus,y, point1(2));
  for j = 1:posNum
      ims = im(idy(j):idy(j)+offset(2)-1,idx(j):idx(j)+offset(1)-1);
      data(:,:,(i-1)*sampleNum+j) = imresize(ims,[width height]);  
      label((i-1)*posNum+j) = 1;
  end  
%  iShow = true;
  if iShow     && i ==1
      figure 
      imshow(im,[]);
      for sn = 1:round(posNum)      
          rectangle('Position',[idx(sn),idy(sn),offset(1),offset(2)],'edgecolor','g');      
          if mod(sn,10) ==0      
              pause();
              clf;                                      % re-draw 
              imshow(im);
          end
      end
  end    

end  

% sample negative samples  HALF BY HALF
alpha = 1/2;    %width
beta = 1/8;     %height   % the height not violent 
indx = sampleNum*posNum;
for i = 1:sampleNum
  x = zeros(1/2.*negNum,1);
  y = zeros(1./2*negNum,1);
  for j = 1:fix(1/2*negNum)
      if rand(1)>0.5
          x(j) = -fix(alpha*randi([width,2*width]));
      else
          x(j) = fix(alpha*randi([width,2*width]));
      end
      if rand(1)>0.5
          y(j) = -fix(beta*randi([height,2*height]));
      else
          y(j) = fix(beta*randi([height,2*height]));
      end
  end
  im = orgdata(:,:,i);
  point1 = cell2mat(fr{i}.p1);
  point2 = cell2mat(fr{i}.p2);
  offset = abs(point1-point2);
  pwidth = offset(1);
  pheight = offset(2);
  
%   iShow = true;
  if iShow   && i ==1    
     imshow(im,[]);
      for sn = 1:fix(negNum/2)
          rectangle('Position',[point1(1)+x(sn),point1(2)+y(sn),pwidth,pheight],'edgecolor','r');    
          if mod(sn,20) ==0
              pause();
              clf;                                      % re-draw 
              imshow(im);
          end
      end 
  end
  for j = 1:fix(negNum/2)
      imf = im( point1(2)+y(j):point1(2)+y(j)+offset(2), point1(1)+x(j):point1(1)+x(j)+offset(1));      
      data(:,:,indx+negNum*(i-1)+2*(j-1)+1) = imresize(imf,[width,height]);
%       label(indx+negNum*(i-1)+2*(j-1)+1) = 0;
  end  
end 

% by IoU < 0.5 IoU >1.5
% 1. makes the negative sample has the same size with positive
% 2. then resize to width*height
minX = 36;
minY = 58;
maxX = 487;
maxY = 512;
negNum2 = fix(negNum/2);
indx = sampleNum*posNum + sampleNum*negNum2; 

for i = 1:sampleNum  
    cont = 1;  
    FLAG = true;
            
    point1 = cell2mat(fr{i}.p1);
    point2 = cell2mat(fr{i}.p2);
    offset = abs(point1-point2);
    pwidth = offset(1);
    pheight = offset(2);
    im = orgdata( :,:,i);
    % for show
    sp = zeros(2,negNum2);
    
    
    while FLAG                              % count the negative number
        if cont > negNum2    
            FLAG = false;
            break;
        end
        x = randi([minX,maxX-pheight],1);
        y = randi([minY,maxY-pwidth],1);
        p2 = [x,y];             
        if getIoU( point1,p2,pwidth,pheight)<0.5 || getIoU(point1,p2,pwidth,pheight)>1.5
%           fprintf('x:%d, y:%d\n',x+pheight-1,y+pwidth-1);
            imf = im( x:x+pheight-1,y:y+pwidth-1);
            % for show 
            sp(:,cont) = [x;y];            
            data(:,:,indx+negNum2*(i-1)+cont) = imresize(imf,[width height]);
            cont = cont + 1;
        end         
    end
    
    % show
%     iShow = true;
    if iShow   && i ==1 
        figure;
        imshow(im);
       for j = 1:(negNum2)
           rectangle('Position',[sp(1,j),sp(2,j),pwidth,pheight],'edgecolor','r');
           if mod(j,20)==0
              pause();
              clf;
              imshow(im);
           end           
       end        
    end
end

end



