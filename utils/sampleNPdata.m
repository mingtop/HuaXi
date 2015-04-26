function [ data, label ] = sampleNPdata( orgdata,lc,width,height,posNum,negNum,iShow )
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
% Farther work£º by hand  and select from neck areas
warning off all
sampleNum = size(lc,2);    
m = sampleNum*(posNum+negNum);
data = zeros(height,width,m);
label = zeros(m,1);
alpha = 1/10;
beta = 1/8;

for i = 1:sampleNum 
  % positive 
  x = randi(fix(alpha*[-width,width]),posNum/2,1);
  y = randi(fix(beta*[-height,height]),posNum/2,1);
  im = orgdata(:,:,i);
  if iShow
      imshow(im,[]);
      for sn = 1:round(posNum/2)      
          h =rectangle('Position',[lc(i).p1(1)+x(sn),lc(i).p1(2)+y(sn),width,height],'edgecolor','g');      
          if mod(sn,10) ==0
                pause(0.1);pause();
          end
      end
  end
  for j = 1:round(posNum/2)
      data(:,:,posNum*(i-1)+2*(j-1)+1) = im(lc(i).p1(1)+x(j):lc(i).p1(1)+x(j)+height-1,lc(i).p1(2)+y(j):lc(i).p1(2)+y(j)+width-1);
      label(posNum*(i-1)+2*(j-1)+1) = 1;
      data(:,:,posNum*(i-1)+2*(j-1)+2) = im(lc(i).p2(1)+x(j):lc(i).p2(1)+x(j)+height-1,lc(i).p2(2)+y(j):lc(i).p2(2)+y(j)+width-1);
      label(posNum*(i-1)+2*(j-1)+2) = 1;
  end
end  


% negative  by auto sample 
alpha = 1/2;    %width
beta = 1/8;     %height   % the height not violent 
indx = sampleNum*posNum;
for i = 1:sampleNum
  x = zeros(1/2.*negNum,1);
  y = zeros(1./2*negNum,1);
  for j = 1:fix(1/2*negNum)
      if rand(1)>0.5
          x(j) = -fix(alpha*randi([width,3*width]));
      else
          x(j) = fix(alpha*randi([width,3*width]));
      end
      if rand(1)>0.5
          y(j) = -fix(beta*randi([height,2*height]));
      else
          y(j) = fix(beta*randi([height,2*height]));
      end
  end
  im = orgdata(:,:,i);
  if iShow
     imshow(im,[]);
      for sn = 1:fix(negNum/2)
          rectangle('Position',[lc(i).p1(1)+x(sn),lc(i).p1(2)+y(sn),width,height],'edgecolor','r');  
          rectangle('Position',[lc(i).p2(1)+x(sn),lc(i).p2(2)+y(sn),width,height],'edgecolor','r');  
          if mod(sn,20) ==0
                 pause(0.1);pause();
          end
      end 
  end
  for j = 1:fix(negNum/2)
      data(:,:,indx+negNum*(i-1)+2*(j-1)+1) = im(lc(i).p1(1)+x(j):lc(i).p1(1)+x(j)+height-1,lc(i).p1(2)+y(j):lc(i).p1(2)+y(j)+width-1);
      label(indx+negNum*(i-1)+2*(j-1)+1) = 1;
      data(:,:,indx+negNum*(i-1)+2*(j-1)+2) = im(lc(i).p2(1)+x(j):lc(i).p2(1)+x(j)+height-1,lc(i).p2(2)+y(j):lc(i).p2(2)+y(j)+width-1);
      label(indx+negNum*(i-1)+2*(j-1)+2) = 1;
  end  
end 
  
end



