function [ BoxLoc ] = preRegionLoc( optthetaF,testData,numClasses,c1filterDim,c1numFilters,c3filterDim,c3numFilters,...
                                s2poolDim,s4poolDim,c5Dim,c6Dim,imageDim,DEBUG )
%PRELOC Detect the location of fracture 
%   random seed from first lc given
%   param:
%       height/width   is the 
% 
    m = size(testData,3);
    width = imageDim;
    height = imageDim;
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
        testImages = reshape(data{i},width,height,size(data{i},3));
        testLabels = 0;
        [~,~,preds]=cnnCost(optthetaF,testImages,testLabels,numClasses,...
                c1filterDim,c1numFilters,c3filterDim,c3numFilters,...
                                s2poolDim,s4poolDim,c5Dim,c6Dim,true);        
        score{i}= preds;  
    end;    
   
   % NMS get largest region 
   topNum = 10;    % get top 10
   thresh = 0.25;  % autoencoder's thresh 
   for i = 1:m
%        I = find(score{i}(1,:) > thresh);                  % the second unit is output
       [~,I] = sort(score{i}(1,:),'descend');
       I = I(1:20);
       scored_boxes = cat(2, boxpatch{i}(I,:), score{i}(1,I)');
%        keep = nms(scored_boxes, 0.3);
%        dets{i} = scored_boxes(keep, :);     
       dets{i} = scored_boxes;
       iShow = true;
       if iShow
           imshow(testData(:,:,i),[]);
           for j = 1:size(dets{i},1)
                rectangle('Position',[dets{i}(j,2) dets{i}(j,1)  dets{i}(j,3)-dets{i}(j,1) dets{i}(j,4)-dets{i}(j,2)],'edgecolor','g');
                str1 = sprintf('%f',dets{i}(j,5));
                text(dets{i}(j,2)+27,dets{i}(j,1)+5,str1,'horiz','center','color','r')
           end
%        frame=getframe(gcf,[1,1,n,m]);  % here has a broads
       frame = getframe(gcf);
       im=frame2im(frame);
       str = sprintf('./test/pic/%d_.jpg',i);
       imwrite(im,str,'jpg');
           pause();
       end

   end
   BoxLoc = j;
   
   

   
   
end

