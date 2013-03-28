clear; close all; clc;

opts.popSize = 20;

opts.lowerBound = [-5 -5];
opts.upperBound = [ 5  5];

opts.eval.handle = @rastrigin;

t = 1e-6;

opts.doe.n = 30; % initial dataset
opts.doe.minTolX = 0.002; % min distance in dataset
opts.doe.maxSampleTries = 20; % max. number of tries when not enough spread samples
opts.sampler.target = t; % testing on x^2, we know the target

rescaleConds = {@stopTolX, @stopTolXDistRatio};
opts.rescale = {
  struct('tolerance', 0.1),
  struct('tolerance', 0.5)
};

restartConds = {@stopStallGen};
opts.restart = {
  struct('generations', 5);
};

stopConds = {@stopTotEvals, @stopTargetReached};
opts.stop = {
  struct('evaluations', 600),
  struct('target', 1e-8)
};

hyp.cov = log([0.1, 0.1]);
hyp.mean = [0];
hyp.lik = log(0.0001);
mean = @meanConst;
cov = @covSEiso;
DIM = size(opts.lowerBound, 2);
opts.model = modelInit(DIM, hyp, mean, cov);

[xopt run] = gpeda(opts, @evalHandle, @doeRandom, @sampleGibbs, rescaleConds, restartConds, stopConds, @gpedaStep2d);

xopt
run
