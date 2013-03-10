function M = modelInit(varargin)
% Creates a new, untrained, GP model allowing to specify mean, covariance, 
% inference and likelihood functions and their initial hyperparameters, 
% while providing sensibel defaults when you're not sure how to choose. 
% 
% Possible calls:
% M = modelInit();
% M = modelInit(hyp);
% M = modelInit(hyp, mean, cov);
% M = modelInit(hyp, mean, cov, lik, inf);
%
% hyp  - hyperparameters struct for GPML with fields: mean, cov, lik
% mean - mean function for GPML (default zero)
% cov  - covariance function for GPML (default @covSEiso)
% lik  - likelihood function for GPML (default @likGauss)
% inf  - inference function for GPML (default @infExact)
%
% Hyperparameter defaults are:
% cov  - for covSEiso: ell (char. length) = 1, sf (signal variance) = 1
% lik  - for likGauss: sn (noise std. deviation) = 0.0001 (almost no expected noise)

if nargin == 0
  hyp.cov = log([1, 1]);
  hyp.lik = log(0.001);
end

if nargin < 2
  mean = [];
  cov = {@covSEiso};

  if ~isfield(hyp, 'cov')
    hyp.cov = log([1, 1]);
  end
end

if nargin < 3
  lik = @likGauss;
  inf = @infExact;

  if ~isfield(hyp, 'inf')
    hyp.inf = log(0.001);
  end
end

% TODO validate hyp struct fields

M = struct( ...
  'hyp', hyp, ...
  'inffunc', inf, ...
  'meanfunc', mean, ...
  'covfunc', cov, ...
  'likfunc', lik ...
);
