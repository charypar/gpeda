clear; close all; clc;

opts.popSize = 10;

opts.lowerBound = [-5 -5];
opts.upperBound = [ 5  5];

opts.eval.handle = @sphere;

t = 1e-6;

opts.doe.n = 20; % initial dataset
opts.sampler.target = t; % testing on x^2, we know the target
opts.stop = {
  struct('evaluations', 100),
  struct('target', t)
};

[xopt run] = gpeda(opts, @evalHandle, @doeRandom, @sampleGibbs, [], {@stopTotEvals, @stopTargetReached}, @gpedaStep2d);

xopt
run
