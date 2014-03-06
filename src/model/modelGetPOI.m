function poi = modelGetPOI(M, x, target, varargin)
% modelGetPOI - returns probability of improvement (POI)
% 
% poi = modelGetPOI(M, x, target) - returns probability of improvement (POI) for specified @target (usually somewhat better than best f(x) sofar) at @x's from model @M
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

% evaluate the PoI
[m s2] = modelPredict(M, x);
% be carefull when dividing by 0 (edit 17/10/2013)
null_variance = (abs(s2) < eps);
q = zeros(n,1);
target_full = repmat(target,n,1);
q(~null_variance) = (target_full(~null_variance) - m(~null_variance)) ./ sqrt(s2(~null_variance));

% save the PoI for x's inside region (lb,ub)
out_of_range = any(x < repmat(lb,n,1) | x > repmat(ub,n,1), 2);
poi = zeros(n,1);
if (sum(out_of_range)<n)
  poi(~out_of_range & ~null_variance) = normcdf(q(~out_of_range & ~null_variance));
end

% % sinus-shape modification (lower for lower values, higher for higer)
% rescale_x = @(x) (x*pi-pi/2);
% rescale_y = @(y) (y + 1)/2;
% poi = rescale_y(sin(rescale_x(poi)));

% poi = (sin(pi*(poi - 1/2)) + 1) / 2;

function cdf = normcdf(x)
  cdf = 0.5 * erfc(-(x)/(sqrt(2)));
end

end
