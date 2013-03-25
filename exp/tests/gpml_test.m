clear all; close all; clc;

% Experiment reproducing the beginning of section 2.3 of the GPML book

meanfunc = {@meanConst}; hyp.mean = [0]; % zero constant mean function
covfunc = {@covSEiso}; ell = 1; sf = 1; hyp.cov = log([ell, sf]); % covariance function with params: ell - char. length, sf - signal variance
likfunc = @likGauss; sn = 0.1; hyp.lik = log(sn); % likelihood function, sn is the noise standard deviation.

% 1.  generate inputs
n = 30;
x = gpml_randn(0.3, n, 1); % inputs drawn from a unit Gaussian

% compute covariance and mean of the GP
K = feval(covfunc{:}, hyp.cov, x); % covariance matrix
m = feval(meanfunc{:}, hyp.mean, x); % mean vector

K = K + eye(n)*0.00001; % Painfully googled correction to make K positive semi-definite

xr = gpml_randn(1.4, n, 1); % sample a n-dimensional standard Gaussian N(0, I)
y = chol(K)' * xr + m; % transform to a Gaussian with covariance matrix K (see end of section A.2 in the GPML book) and add mean
y = y + exp(hyp.lik) * gpml_randn(0.1, n, 1); % finally, add noise

% 2. predict with same parameters

z = linspace(-5, 5, 101)';
[m s2] = gp(hyp, @infExact, meanfunc, covfunc, likfunc, x, y, z);

subplot(1, 2, 1);
plotErr1(z, m, s2, x, y);
title('Prediction with original hyperparameters');
axis([-5 5 -2.5 2.5]);

%3. now let's try to learn the hyperparameters
% Note that here we are guesssing the structure of the underlying generating process correctly
covfunc = @covSEiso; hyp2.cov = [0; 0]; sn = 0.1; hyp2.lik = log(sn);

% minimize nlml, params are: the initial guess, function, length, 
% and then params for the gp function (training mode): inference, mean, covariance, x and y vectors
hyp2 = minimize(hyp2, @gp, -500, @infExact, [], covfunc, likfunc, x, y);

[m s2] = gp(hyp2, @infExact, [], covfunc, likfunc, x, y, z);

disp(['original hyperparameters:']);
hyp.cov
hyp.lik

disp(['learned hyperparameters:']);
hyp2.cov
hyp2.lik

subplot(1, 2, 2);
plotErr1(z, m, s2, x, y);
title('Prediction with learned hyperparameters (and correct process structure)');
axis([-5 5 -2.5 2.5]);

