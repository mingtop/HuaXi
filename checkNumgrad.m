function numgrad = checkNumgrad( J,theta )
%
%
numgrad = zeros(size(theta));
e = 0.0001;
for i = 1:size(theta)
    E_plus = theta;
    E_sub = theta;
    E_plus(i) = theta(i)+e;
    E_sub(i) = theta(i)-e;
    numgrad(i) = (J(E_plus)-J(E_sub))./(2*e);    
   if mod(i,500)==0
        disp(i); 
   end
end
end

