function rule_dist = measureRules(Features, Rules, varargin)
  if length(varargin) < 1 
    toEuclid = true;
  else
    toEuclid = varargin{1};
  end
  
  nbRules = size(Rules,1);
  rule_dist = zeros(nbRules,1);
  validIndex = ~isnan(Features);
  for idr = 1 : nbRules
    if toEuclid
      rule_dist(idr) = dist2(Features(validIndex), Rules(idr,validIndex)); %fprintf("Euclidean distance\n");
    else
      rule_dist(idr) = distRadialKernel(Features(validIndex), Rules(idr,validIndex)); % fprintf("Radial Kernel based distance\n");
    end
  end
end