function Y = Rastrigin(X)
  % Objective function definition
  Nd = size(X,2);    
  term1 = X.^2;
  term2 = 10*cos(2*pi*X);
  
  f_x = 0;
  f_x = f_x + sum(term1 - term2,2);
  f_x = f_x + 10 * Nd;
  
  Y = f_x;
end