clear; close all; clc;

opts.popSize = 8;
% % 1D
opts.lowerBound = -5;
opts.upperBound =  5;

% opts.eval.handle = @(x) ( sum(x.^2, 2) );
opts.eval.handle = @rastrigin;
target = 1e-7;

opts.doe.n = 20; % initial dataset
opts.doe.minTolX = 0.002; % min distance in dataset
opts.doe.maxSampleTries = 20; % max. number of tries when not enough spread samples
opts.sampler.target = target; % testing on x^2, we know the target
opts.rescale = {
  struct('tolerance', 0.05),
  struct('tolerance', 0.5)
};
opts.restart = {
  struct('generations', 5)
};
opts.stop = {
  struct('evaluations', 200),
  struct('target', target)
};

% % 1D
[xopt run] = gpeda(opts, @evalHandle, @doeRandom, @sampleGibbs, ...
                   {@stopTolX, @stopTolXDistRatio}, {@stopStallGen}, {@stopTotEvals, @stopTargetReached}, @gpedaStep1d);


figure;
plotRun(run);

xopt
run
