function d = dist2(X,Y)
  d = sqrt( sum((X-Y).^2, 2) );
end