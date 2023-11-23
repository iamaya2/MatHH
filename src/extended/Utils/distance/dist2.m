function d = dist2(X,Y)
% dist2 - Euclidean distance between two matrices. Each row in the matrices
% represent a different solution, and each column a dimension of a
% solution.
%
% Input:
%  X,Y - Matrices where each row is a different solution
%
% Output:
%  d - Euclidean distance between each pair of solutions
%
% Note: This method is intended to be used with HHs, so that input Y
% contains the same information in each row, which stands for the current
% feature vector of the model. 
%
% See also: RULEBASEDSELECTIONHH
  d = sqrt( sum((X-Y).^2, 2) );
end