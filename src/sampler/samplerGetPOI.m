function poi = samplerGetPOI(M, z, target)

[m s2] = modelPredict(M, z);
q = (target - m) ./ sqrt(s2);

poi = normcdf(q);
