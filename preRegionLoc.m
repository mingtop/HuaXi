function [ BoxLoc ] = preRegionLoc( optthetaF,testData,fr,width,height,inputSize,hiddenSize,classNum,DEBUG )
%PRELOC Detect the location of fracture 
%   random seed from first lc given
%   param:
%       height/width   is the 
% 
    

    m = size(testData,3);
    
    % decode optthetaF
    w1 = reshape(optthetaF(1:inputSize*hiddenSize),hiddenSize,inputSize);
    b1 = reshape(optthetaF(inputSize*hiddenSize+1:inputSize*hiddenSize+hiddenSize),hiddenSize,1);
    w2 = reshape(optthetaF(inputSize*hiddenSize+hiddenSize+1:inputSize*hiddenSize+hiddenSize+hiddenSize*classNum),classNum,hiddenSize);
    b2 = reshape(optthetaF(inputSize*hiddenSize+hiddenSize+hiddenSize*classNum+1:end),classNum,1);
    f = @(x) 1./(1+exp(-x));   
    
    % canddite region  
    disp('1. calculate candidate region');
    boxpatch = getSelective_search(testData);
    
    % init data 
    for i = 1:m
       im = testData(:,:,i);
       n = size(boxpatch{i},1);
       tdata = zeros(width,height,n);
       for j = 1:n;
           p = boxpatch{i}(j,:); 
           pwidth = p(3)-p(1);
           pheight = p(4)-p(2);
           % 验证是否需要去除   % crop some large crops   
           if pwidth > 400 || pheight >400
           end
           tdata(:,:,j) = imresize(im(p(1):p(3),p(2):p(4)),[width height]);
       end; 
       data{i} = tdata;           
    end

    % do prediction
    disp('2. calculate similarity');
    for i = 1:m
        % compute every picture's candidate orgions 
        data1 = reshape(data{i},width*height,size(data{i},3));
        z2 = bsxfun(@plus, w1 * data1,b1);
        a2 = f(z2);
        z3 = bsxfun(@plus,w2*a2,b2);
        score{i}= f(z3);  
    end;    
   
   % NMS get largest region 
   topNum = 10;
   thresh = 0.25;
   for i = 1:m
       I = find(score{i}(2,:) > thresh);                  % the second unit is output
       scored_boxes = cat(2, boxpatch{i}(I,:), score{i}(2,I)');
       keep = nms(scored_boxes, 0.3);
       dets{i} = scored_boxes(keep, :);
       
       iShow = true;
       if iShow
           imshow(testData(:,:,i),[]);
           for j = 1:size(dets{i},1)
                rectangle('Position',[dets{i}(j,2) dets{i}(j,1) dets{i}(j,3)-dets{i}(j,1) dets{i}(j,4)-dets{i}(j,2)],'edgecolor','g');               
           end
       frame=getframe(gcf,[1,1,n,m]);  % here has a broads
       frame = getframe(gcf);
       im=frame2im(frame);
       str = sprintf('./test/pic/%d_.jpg',i);
       imwrite(im,str,'jpg');

           pause();
       end
           
           
%        all_dets = [];
%        for i = 1:length(dets)
%            all_dets = cat(1, all_dets, ...
%                [i * ones(size(dets{i}, 1), 1) dets{i}]);
%        end
%        
%        [~, ord] = sort(all_dets(:,end), 'descend');
   end
   BoxLoc = j;
   
   
% get maxPre box and draw out the box on the image!
%   for i=1:m
%        [s(i), indx(i)] = max(score{i}(2,:));            
%        imshow(testData(:,:,i),[]);
%         p = boxpatch{i}(indx(i),:); 
%        rectangle('Position',[ p(2), p(1),p(3) - p(1),p(4)-p(2)],'edgecolor','g');
%        pause();
%        if DEBUG
% %        %  show the canddiate box and persuit box
% %        for j = 1:num
% %           if mod(j,10)==0             
% %               pause(); 
% %               clf
% %               imshow(testData(:,:,i),[]);
% %               rectangle('Position',[X1(indx(1,i)),Y1(indx(2,i)),width,height],'edgecolor','g');
% %               % draw text 
% % %               xlim=get(gca,'xlim');
% % %               ylim=get(gca,'ylim');
% % %               N=100;
% % %               text(sum(xlim)/2,sum(ylim)/2+N,'想要添加的文字','horiz','center','color','g')
% %           end
% %           rectangle('Position',[X1(j),Y1(j),width,height],'edgecolor','r');
% %        end      
%        end
% %        rectangle('Position',[X2(indx(1,i)),Y2(indx(2,i)),width,height],'edgecolor','g');
%        pause();
%      imwrite(testData(:,:,i),'a.jpg');  % saved a no rectangle and  binary picture
%      [m,n] = size(testData(:,:,i));
%      frame=getframe(gcf,[1,1,n,m]);  % here has a broads
%        frame = getframe(gcf);
%        im=frame2im(frame);
%        str = sprintf('./results/pic/%d_.jpg',i);
%        imwrite(im,str,'jpg');
%        
%    end
%    
%    BoxLoc.socre = s(:);
%    BoxLoc.indx = indx(:);
   
   
end

