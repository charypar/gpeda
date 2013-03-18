clear; close all; clc;

opts.popSize = 10;
% % 1D
% opts.lowerBound = [-5 -5];
% opts.upperBound = [ 5  5];

% 2D
opts.lowerBound = [-5 -5];
opts.upperBound = [ 5  5];

% opts.eval.handle = @(x) ( sum(x.^2, 2) );
% opts.eval.handle = @rastrigin;
opts.eval.handle = @sphere;

opts.doe.n = 20; % initial dataset
opts.sampler.target = 0; % testing on x^2, we know the target
opts.stop.evaluations = 100;

% % 1D
% [xopt run] = gpeda(opts, @evalHandle, @doeRandom, @sampleGibbs, [], @stopNEvals, @gpedaStep2d);

% 2D
[xopt run] = gpeda(opts, @evalHandle, @doeRandom, @sampleGibbs, [], @stopNEvals, @gpedaStep2d);

xopt
run
