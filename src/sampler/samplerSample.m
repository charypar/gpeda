function pop = samplerSample(M, lb, ub, n, spar, varargin)
% Samples a population of n individuals based on the model M
%
% Possible calls:
% pop = samplerSample(M, lb, ub, n, spar)
% pop = samplerSample(M, lb, ub, n, spar, strategyFunc)
%
% M      - the model structure
% lb, ub - lower and upper bound (coordinate-wise)
% n      - number of samples to obtain
% spar   - parameter struct for the sampling strategy (for the default MCPOI you need a target field)

if nargin > 5
  strategyFunc = varargin{1};
else
  strategyFunc = @samplerMCPOI;
end

pop = zeros(n, M.dim);

for i = 1:n 
  sample = feval(strategyFunc, M, lb, ub, spar.target);
  pop(i, :) = sample;
end


