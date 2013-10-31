function ei = modelGetEI(M, x, best_y, varargin)
% modelGetEI - returns Expected Improvement (EI) for a given model and input x
%
%          /    (best_y - model_y(x))*NCDF(z) + model_std(x)*NPDF(z)    if model_std(x) > 0
% EI(x) = <
%          \    0                                                       if model_std(x) == 0
% 
% ei = modelGetEI(M, x, best_y) - returns expected improvement (EI) at @x for the function 
%       modelled by the model @M, so-far reached minimum value @best_y
%
% x     vector or matrix of size n by D (n = # of samples, D = dimension)

% lower/upper bounds, default: [-1, 1]
if (nargin > 3)
  lb = varargin{1};
elseif (nargin > 4)
  ub = varargin{2};
else
  dim = size(x, 2);
  lb = -1 * ones(1,dim);
  ub =  1 * ones(1,dim);
end
n = size(x,1);

% evaluate the EI
[y s2] = modelPredict(M, x);
% be carefull when dividing by 0
null_variance = (abs(s2) < eps);
z = zeros(n,1);
best_y_full = repmat(best_y,n,1);
z(~null_variance) = (best_y_full(~null_variance) - y) ./ sqrt(s2(~null_variance));

% save the PoI for x's inside region (lb,ub)
out_of_range = any(x < repmat(lb,n,1) | x > repmat(ub,n,1), 2);
ei = zeros(n,1);
if (sum(out_of_range)<n)
  ei(~out_of_range & ~null_variance) = (best_y_full - y).*normcdf(z) + s2.*normpdf(z);
end

function cdf = normcdf(x)
  cdf = 0.5 * erfc(-(x)/(sqrt(2)));
end

function pdf = normpdf(x)
  pdf = exp(-0.5 * x.^2) ./ sqrt(2*pi);
end

end
