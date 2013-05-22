function d = distToDataset(x, dataset)
%distToDataset - computes vector of distances between *x* and *dataset*
% TODO: rewrite with bsxfun() instead of repmat()
  xs = repmat(x, size(dataset,1), 1);
  ds = (xs - dataset);
  d  = sqrt(sum(ds.^2,2));
end

