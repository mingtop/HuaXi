function [ BoxLoc ] = preRandLoc( optthetaF,testData,lc,width,height,inputSize,hiddenSize,classNum,DEBUG )
%PRELOC Detect the location of fracture 
%   random seed from first lc given
%   param:
%       height/width   is the 
% 
    
    num = 50;
    thresthold = 0.95;
    m = size(testData,3);

    xlim = [-12,12];
    ylim = [-12,12];
    
    % decode optthetaF
    w1 = reshape(optthetaF(1:inputSize*hiddenSize),hiddenSize,inputSize);
    b1 = reshape(optthetaF(inputSize*hiddenSize+1:inputSize*hiddenSize+hiddenSize),hiddenSize,1);
    w2 = reshape(optthetaF(inputSize*hiddenSize+hiddenSize+1:inputSize*hiddenSize+hiddenSize+hiddenSize*classNum),classNum,hiddenSize);
    b2 = reshape(optthetaF(inputSize*hiddenSize+hiddenSize+hiddenSize*classNum+1:end),classNum,1);
    f = @(x) 1./(1+exp(-x));   
    % canddite pixel
    org1X = lc(1).p1(1);
    org1Y = lc(1).p1(2);
    org2X = lc(1).p2(1);
    org2Y = lc(1).p2(2);
    X1 = randi(xlim,num,1) + fix(org1X);
    Y1 = randi(ylim,num,1) + fix(org1Y);
    X2 = randi(xlim,num,1) + fix(org2X);
    Y2 = randi(ylim,num,1) + fix(org2Y);

    % sample pre origin
    data1 = zeros(width*height,num,m);   
    data2 = zeros(width*height,num,m);
    for i = 1:m        
        for j=1:num
            data1(:,j,i) = reshape(testData(X1(j):X1(j)+height-1,Y1(j):Y1(j)+width-1,i),width*height,1);
            data2(:,j,i) = reshape(testData(X2(j):X2(j)+height-1,Y2(j):Y2(j)+width-1,i),width*height,1);            
        end
    end
    data1 = normalizeData(data1);
    data2 = normalizeData(data2);  
    
%     %add noise 
    data1 = noise_set(data1,1,0.1);
    data2 = noise_set(data2,1,0.1);
    
    
    % do prediction 
    score1 = zeros(classNum,num,m);
    score2 = zeros(classNum,num,m);
    for i = 1:m
        % compute every picture's candidate orgions 
        z2 = bsxfun(@plus, w1 * data1(:,:,i),b1);
        a2 = f(z2);
        z3 = bsxfun(@plus,w2*a2,b2);
        score1(:,:,i) = f(z3);
        
        z2 = bsxfun(@plus, w1 * data2(:,:,i),b1);
        a2 = f(z2);
        z3 = bsxfun(@plus,w2*a2,b2);
        score2(:,:,i) = f(z3);    
    end;
    
   % get maxPre box and draw out the box on the image!
   s = zeros(2,m);
   indx = zeros(2,m);
   for i = 1:m       
       [s(1,i) , indx(1,i)] = max(score1(2,:,i));
       [s(2,i) , indx(2,i)] = max(score2(2,:,i));              
       imshow(testData(:,:,i),[]);
       rectangle('Position',[X1(indx(1,i)),Y1(indx(2,i)),width,height],'edgecolor','g');
       
       if DEBUG
%        %  show the canddiate box and persuit box
%        for j = 1:num
%           if mod(j,10)==0             
%               pause(); 
%               clf
%               imshow(testData(:,:,i),[]);
%               rectangle('Position',[X1(indx(1,i)),Y1(indx(2,i)),width,height],'edgecolor','g');
%               % draw text 
% %               xlim=get(gca,'xlim');
% %               ylim=get(gca,'ylim');
% %               N=100;
% %               text(sum(xlim)/2,sum(ylim)/2+N,'想要添加的文字','horiz','center','color','g')
%           end
%           rectangle('Position',[X1(j),Y1(j),width,height],'edgecolor','r');
%        end      
       end
       rectangle('Position',[X2(indx(1,i)),Y2(indx(2,i)),width,height],'edgecolor','g');
       pause();
%      imwrite(testData(:,:,i),'a.jpg');  % saved a no rectangle and  binary picture
%      [m,n] = size(testData(:,:,i));
%      frame=getframe(gcf,[1,1,n,m]);  % here has a broads
       frame = getframe(gcf);
       im=frame2im(frame);
       str = sprintf('./results/pic/%d_.jpg',i);
       imwrite(im,str,'jpg');
       
   end
   
   BoxLoc.socre = s(:);
   BoxLoc.indx = indx(:);
   
   
end

