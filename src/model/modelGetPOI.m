function poi = modelGetPOI(M, x, target)

[m s2] = modelPredict(M, x);
q = (target - m) ./ sqrt(s2);

poi = normcdf(q);
