function [ net ] = minFuncSGD( net,input )
%MINFUNCSGD 
alpha = net.opt.alpha;
batchSize = net.opt.batchSize;
epoches = net.opt.epoches;
mom = net.opt.momentum;
m = size(input,2);
% init velocity
for i = 1:length(net.layer)-1
    velocity.w{i} = 0;
    velocity.b{i} = 0;
end

for i = 1:epoches
    I = randperm(m);
    for j = 1:batchSize:m %(m/batchSize)*batchSize
        if j+batchSize > m
            x = input(:,I(j:m));
        else
            x = input(:,I(j:j+batchSize-1));
        end;                
        % grad
        [net,cost] = AEcost(net,x); % add gradw gardb
        
        % updata
        for k = 1:length(net.layer)-1
            velocity.w{k} = velocity.w{k} + alpha*(net.gradw{k});
            velocity.b{k} = velocity.b{k} + alpha*(net.gradb{k});
            net.w{k} = mom*net.w{k} - velocity.w{k};
            net.b{k} = mom*net.b{k} - velocity.b{k};
        end

        % print debug info
%         if mod( j-1 ,20*batchSize) == 0
%             fprintf('%d/%d, Iter:%d   alpha:%f  cost: %f \n',i,epoches,j,alpha,cost);
%         end
        
        
    end  
    if i > 1/2*epoches
            alpha = 0.9*alpha;
    end
    fprintf('%d/%d, Iter:%d   alpha:%f  cost: %f \n',i,epoches,j,alpha,cost);
end

end

