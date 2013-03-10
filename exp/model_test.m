clear all; close all; clc;

meanfunc = {@meanConst}; hyp.mean = [0]; % zero constant mean function
covfunc = {@covSEiso}; ell = 1; sf = 1; hyp.cov = log([ell, sf]); % covariance function with params: ell - char. length, sf - signal variance
likfunc = @likGauss; sn = 0.1; hyp.lik = log(sn); % likelihood function, sn is the noise standard deviation.

% 1.  generate inputs (this part is the same as gpml_test)
n = 30;
x = gpml_randn(0.3, n, 1); % inputs drawn from a unit Gaussian

% compute covariance and mean of the GP
K = feval(covfunc{:}, hyp.cov, x); % covariance matrix
m = feval(meanfunc{:}, hyp.mean, x); % mean vector

K = K + eye(n)*0.00001; % Painfully googled correction to make K positive semi-definite

xr = gpml_randn(1.4, n, 1); % sample a n-dimensional standard Gaussian N(0, I)
y = chol(K)' * xr + m; % transform to a Gaussian with covariance matrix K (see end of section A.2 in the GPML book) and add mean
y = y + exp(hyp.lik) * gpml_randn(0.1, n, 1); % finally, add noise

% Train a model on the samples and make predictions

M = modelInit(); % the default
M = modelTrain(M, x, y);

z = linspace(-5, 5, 101)';
[m s2] = modelPredict(M, z);

poi = samplerGetPOI(M, z, -1.3);

plotErr1(z, m, s2, x, y);
title('Prediction with learned hyperparameters (and correct process structure)');

hold on;
plot(z, poi, 'g-');
plot([-5 5], [0 0], 'k-');
plot([-5 5], [-1.3 -1.3], 'k--');
