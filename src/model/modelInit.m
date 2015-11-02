function M = modelInit(dim, varargin)
% Creates a new, untrained, GP model allowing to specify mean, covariance, 
% inference and likelihood functions and their initial hyperparameters, 
% while providing sensibel defaults when you're not sure how to choose. 
% 
% Possible calls:
% M = modelInit(dim);
% M = modelInit(dim, hyp);
% M = modelInit(dim, hyp, mean, cov);
% M = modelInit(dim, hyp, mean, cov, lik, inf);
%
% dim  - dimension of the input space
% hyp  - hyperparameters struct for GPML with fields: mean, cov, lik
% mean - mean function for GPML (default zero)
% cov  - covariance function for GPML (default @covSEiso)
% lik  - likelihood function for GPML (default @likGauss)
% inf  - inference function for GPML (default @infExact)
%
% Hyperparameter defaults are:
% cov  - for covSEiso: ell (char. length) = 1, sf (signal variance) = 1
% lik  - for likGauss: sn (noise std. deviation) = 0.0001 (almost no expected noise)

if nargin > 1
  hyp = varargin{1};
else
  hyp.cov = log([0.05 0.1]);
  hyp.lik = log(0.0001);
end

mean = {@meanConst};
cov = {@covSEiso};

if ~isfield(hyp, 'cov')
  hyp.cov = log([ones(1,dim), 1]);
end
if ~isfield(hyp, 'mean')
  hyp.mean = [0];
end
if nargin >= 3
  mean = varargin{2};
end
if nargin >= 4
  cov = varargin{3};
end

if nargin < 5
  lik = @likGauss;
  inf = @infExact;
  % inf = @infLaplace;

  % if ~isfield(hyp, 'inf')
  %   hyp.inf = log(0.001);
  % end
  if ~isfield(hyp, 'lik')
    hyp.lik = log(0.0001);
  end
else
  lik = varargin{4};
  inf = varargin{5};
end

% TODO validate hyp struct fields

M = struct( ...
  'dim', dim, ...
  'hyp', hyp, ...
  'inffunc', inf, ...
  'meanfunc', mean, ...
  'covfunc', cov, ...
  'likfunc', lik ...
);

% This is a work-around:
% to be able to fill a 2-value cell array into struct in initialization, it 
% has to be in "doubled" cell array: {{covfunc, param1}}. Here, the doubled
% cellarray is deleted.
if (iscell(M.covfunc) && iscell(M.covfunc{1}))
  M.covfunc = M.covfunc{:};
end

end
