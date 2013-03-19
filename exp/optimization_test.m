clear; close all; clc;

opts.popSize = 5;
% % 1D
opts.lowerBound = -5;
opts.upperBound =  5;

% opts.eval.handle = @(x) ( sum(x.^2, 2) );
opts.eval.handle = @rastrigin;
target = 1e-5;

opts.doe.n = 10; % initial dataset
opts.sampler.target = target; % testing on x^2, we know the target
opts.restart = {
  struct('generations', 4)
};
opts.stop = {
  struct('evaluations', 200),
  struct('target', target)
};

% % 1D
[xopt run] = gpeda(opts, @evalHandle, @doeRandom, @sampleGibbs, {@stopStallGen}, {@stopTotEvals, @stopTargetReached}, @gpedaStep1d);


figure;
plotRun(run);

xopt
run
