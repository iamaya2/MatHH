function [nPerms,pInds,Perms] = uniqperms(x,k,first)
%uniqperms: unique permutations of an input vector x
% Usage:  nPerms              = uniqperms(x)
%        [nPerms pInds]       = uniqperms(x)
%        [nPerms pInds Perms] = uniqperms(x)
%        [nPerms pInds]       = uniqperms(x, k)
%        [nPerms pInds Perms] = uniqperms(x, k)
%        [nPerms pInds Perms] = uniqperms(x,k,first)
%
% Determines number of unique permutations (nPerms) for vector x.
% Optionally, all permutations indices (pInds) are returned. If requested,
% permutations of the original input (Perms) are also returned.
%
% If k < nPerms, a random (but still unique) subset of k of permutations is
% returned. 
%
% If k >= nPerms, a random (but still unique) subset of nPerms of permutations is
% returned. The original/identity permutation will be the first of these.
%
% Row or column vector x results in Perms being a [k length(x)] array,
% consistent with MATLAB's built-in perms. pInds is also [k length(x)].
% 
% If first = true then the original/identity permutation will be the first of these.
% (first = false ... opposite case)
%
% Examples:
%  uniqperms(1:7),       factorial(7)                          % verify counts in simple case,
%  uniqperms([1 1 2]),   factorial(3)/prod(factorial([2 1]))   % verify counts in nonunique case,
% [nPerms,pInds Perms] = uniqperms([1 1 1 2 2], 3))
% nPerms =
%     10
% 
% pInds =
% 
%      1     3     2     5     4
%      1     3     5     2     4
%      1     3     5     4     2
% 
% Perms =
% 
%      1     1     1     2     2
%      1     1     2     1     2
%      1     1     2     2     1
%

% Copyright 2018 Michal Kvasnicka
% UJV Rez, a.s.


%% Usage
if isempty(x) || isscalar(x) || ~isvector(x)
    error('Input x must be a vector')
else
    % transform x to row vector
    x = x(:)';
    % Length of input vector
    nx = length(x);
end

if nargin < 3
    % Default value of "first"
    first = false;
end

%% Count number of repetitions of unique row vector x
m = histcounts(x,length(unique(x)));
nPerms = factorial(nx)/prod(factorial(m));

if nargout < 2, return, end

%% Choose proper k
if isinf(nPerms)
    error('Sorry, number of possible permutations is too big!');
elseif nargin < 2 || k > nPerms
    k = nPerms;
end

%% Unique permutation generation 
if first
    % (the original/identity permutation will be the first of these)
    Perms = x;
    pInds = 1:nx;
else
    % (the original/identity permutation will not be the first of these)
    Perms = [];
    pInds = [];
end

% loop over k random permutations
while true
    [~,pI] = sort(rand(k,nx),2);
    iaux = [pInds;pI];
    [Perms,pI] = unique([Perms;x(pI)],'rows','stable');
    pInds = iaux(pI,:);
    if size(Perms,1) >= k
        break;
    end
end

% reduction of final permutations number up to k
if size(Perms,1) > k
    Perms = Perms(1:k,:);
    pInds = pInds(1:k,:);
end

end
