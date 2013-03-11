function [x y varargout] = testGP(n, sn)
% return values are either [x y] or [x y proc]

meanfunc = {@meanConst}; hyp.mean = [0]; % zero constant mean function
covfunc = {@covSEiso}; ell = 1; sf = 1; hyp.cov = log([ell, sf]); % covariance function with params: ell - char. length, sf - signal variance
likfunc = @likGauss; hyp.lik = log(sn); % likelihood function, sn is the noise standard deviation.

% 1.  generate inputs (this part is the same as gpml_test)
x = gpml_randn(0.3, n, 1); % inputs drawn from a unit Gaussian

% compute covariance and mean of the GP
K = feval(covfunc{:}, hyp.cov, x); % covariance matrix
m = feval(meanfunc{:}, hyp.mean, x); % mean vector

K = K + eye(n)*0.00001; % Painfully googled correction to make K positive semi-definite

xr = gpml_randn(1.4, n, 1); % sample a n-dimensional standard Gaussian N(0, I)
y = chol(K)' * xr + m; % transform to a Gaussian with covariance matrix K (see end of section A.2 in the GPML book) and add mean
y = y + exp(hyp.lik) * gpml_randn(0.1, n, 1); % finally, add noise

if nargout > 2
  varargout(1) = struct( ...
    'meanfunc', meanfunc, ...
    'covfunc', covfunc, ...
    'likfunc', likfunc, ...
    'hyp',  hyp ...
  );
end
