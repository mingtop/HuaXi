function [ output ] = noise_set( input,type,rio )
%NOISE_SETZEROS  
%   params:
%        rio = the ratio set input to zeros 
%        type  1: set zeros by rio 
    [m,n,num] = size(input);
    output = zeros(m,n,num);
    for i = 1:num
        if type ==1  
            setX = rand(m,n)> rio;
        end        
        if type == 2   % to add gaussian 
            setX = random('norm',0,1,m,n);   % mean=0,var=1, var maybe large
        end
        output(:,:,i) = input(:,:,i).*setX;        
    end




end

