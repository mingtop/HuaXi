function [ opttheta ] = miniFunFSGD( funObj,theta,data,orgLabel,opt )

epoches = opt.epoches;
batchSize = opt.batchSize;
alpha = opt.alpha;
threshold = opt.threshold;
m = size(data,3);

mom = 0.5;
momIncreasment = 20;
velocity = zeros(size(theta));

error = [];
figure ;
it = 1;  


for epoch = 1:epoches    
    rp = randperm(m);
    for s = 1:batchSize:m-batchSize+1
        if s+batchSize > m                % the sample is very large always 1000 times ,so don't need consider this
            input = data(:,:,rp(s:end)); 
            label = orgLabel(:,s:end);
        else 
            input = data(:,:,rp(s:s+batchSize-1));
            label = orgLabel(:,rp(s:s+batchSize-1));
        end;
        if it == momIncreasment 
            mom = opt.momentum;            
        end;        
        
        input = noise_set(input,1,0.1);  % set input to 0 by 10% possibilty
        
        [~,grad,err] = funObj(theta,input,label);        
        % updata weight 
        velocity = mom.*velocity  + alpha.* grad;
        theta = theta - velocity;    
        error = [error,err];
        plot(error);
        pause(0.1);                 
    end
    % for updata mom and alpha
    it = it +1;                 
    if   ceil(epoches/2)   
        alpha = alpha/2;
    end
    % end 
    if err < threshold
        fprintf('the minfunSGD out of threshold %f\n',threshold); 
        opttheta = theta;
        break;
    end
    % save 
    if mod(epoch,10) == 0
       str  = sprintf('./temp/theta%d.mat',epoch);
       save(str,'theta');
    end
    fprintf('epoches %d alpha: %f \n',epoch,alpha);
end
opttheta = theta;

end