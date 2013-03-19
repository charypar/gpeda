clear; close all; clc;

opts.popSize = 10;

opts.lowerBound = [-5 -5];
opts.upperBound = [ 5  5];

opts.eval.handle = @sphere;

opts.doe.n = 20; % initial dataset
opts.sampler.target = 0; % testing on x^2, we know the target
opts.stop.evaluations = 100;

[xopt run] = gpeda(opts, @evalHandle, @doeRandom, @sampleGibbs, [], @stopTotEvals, @gpedaStep2d);

xopt
run
