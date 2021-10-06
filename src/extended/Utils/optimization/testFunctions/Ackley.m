function Y = Ackley(X)
  % Objective function definition
  Nd = size(X,2);    
  sum1 = sum(X.^2,2);
  sum2 = sum(cos(2*pi*X),2);		
  
  f_x = 20 + exp(1);
  f_x += -20 * exp(-0.2*sqrt(sum1/Nd))  -  exp( sum2/Nd );		
  
  Y = f_x;
end