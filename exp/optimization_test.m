clear; close all; clc;

opts.popSize = 10;
opts.lowerBound = -5;
opts.upperBound = 5;

opts.eval.handle = @(x) ( sum(x.^2, 2) );
% opts.eval.handle = @rastrigin;
opts.doe.n = 20; % initial dataset
opts.sampler.target = 0.001; % testing on x^2, we know the target
opts.stop.evaluations = 100;

xopt = gpeda(opts, @evalHandle, @doeRandom, @samplerMCPOI, [], @stopNEvals, @gpedaStep1d);

xopt
