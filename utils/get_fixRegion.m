function [ fr ] = get_fixRegion( data,sampleNum )
% parameter :
%       fr:  is an cell store every picture's ROI region 
%                 fr(i) ---> .num : number of region in this picture
%                            .p1  :  p1(i) and p2(i) consist a rectangle .
%                                    p1 is the left-up point
%                            .p2  £º p2 is the right-bottom point
%      data:  is gray picture matrix.    width*height*number
%      sampleNum: number of picture to calibration

for i = 1:sampleNum
    im = data(:,:,i);
    imshow(im);
    pause(0.01);
    j = 0;  % count the number of rectangle;    
    while true
        k = waitforbuttonpress;            % wait mouse clicked
        point1 = get(gca,'CurrentPoint');    % button down detected
        finalRect = rbbox;                   % return figure units
        point2 = get(gca,'CurrentPoint');    % button up detected
        point1 = point1(1,1:2);              % extract x and y
        point2 = point2(1,1:2);
        p1 = min(point1,point2);             % calculate locations
        offset = abs(point1-point2);         % and dimensions
        x = [p1(1) p1(1)+offset(1) p1(1)+offset(1) p1(1) p1(1)];
        y = [p1(2) p1(2) p1(2)+offset(2) p1(2)+offset(2) p1(2)];
        hold on
        h1 = plot(x,y,'b');
        pause();
        a = get(gcf,'CurrentCharacter');
        if a == 's'
            j = j+1;
            fr{i}.num = j;
            fr{i}.p1{j} = point1;
            fr{i}.p2{j} = point2;      
            plot(x,y,'g');
            fprintf(' %d regions  saved \n',j);
        elseif a =='x'            
            fprintf('%d picture end, total: %d rect saved! \n',i,j);
            break;
        else 
            delete(h1);
        end
    end
end





end

