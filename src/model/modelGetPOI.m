function poi = modelGetPOI(M, x, target)
% modelGetPOI - returns probability of improvement (POI)
% 
% poi = modelGetPOI(M, x, target) - returns probability of improvement (POI) for specified @target (usually somewhat better than best f(x) sofar) at @x's from model @M
%
% x     vector or matrix of size n by D (n = # of samples, D = dimension)

[m s2] = modelPredict(M, x);
q = (target - m) ./ sqrt(s2);

poi = normcdf(q);
