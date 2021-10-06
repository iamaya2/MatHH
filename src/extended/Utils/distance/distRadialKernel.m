function d = distRadialKernel(X,Y)
%  gamma = 1 / size(X,2); % Sets gamma in function of the number of dimensions
  gamma = 2; % Sets gamma in function of the number of dimensions
  d11 = dist2(X,X); % Calculates norm between points
  d12 = dist2(X,Y); % Calculates norm between points
  d22 = dist2(Y,Y); % Calculates norm between points
  
  d = exp(-gamma * d11) + exp(-gamma * d22) - 2*exp(-gamma * d12);
  %d = (X * X').^2 + (Y * Y').^2 - 2 * (X * Y').^2
end