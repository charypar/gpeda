function poi = modelGetPOI(M, x, target)
% modelGetPOI - returns probability of improvement (POI)
% 
% poi = modelGetPOI(M, x, target) - returns probability of improvement (POI) for specified @target (usually somewhat better than best f(x) sofar) at @x's from model @M
%
% x     vector or matrix of size n by D (n = # of samples, D = dimension)

[m s2] = modelPredict(M, x);
q = (target - m) ./ sqrt(s2);

out_of_range = any(abs(x) > 1, 2);
poi(out_of_range) = 0;
poi(~out_of_range) = normcdf(q);

function cdf = normcdf(x)
  cdf = 0.5 * erfc(-(x)/(sqrt(2)));
end

end
