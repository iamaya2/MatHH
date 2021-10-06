function Y = ShiftedJong(X)  
A = 2;
Nd = size(X,2);
idx = 1:Nd;
  Y = sum((X-idx*A).^2 , 2); % Sweeps columns and sum
end