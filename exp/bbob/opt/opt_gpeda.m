function xbest = opt_gpeda(FUN, DIM, ftarget, maxfunevals)
% MY_OPTIMIZER(FUN, DIM, ftarget, maxfunevals)
% samples new points uniformly randomly in [-5,5]^DIM
% and evaluates them on FUN until ftarget of maxfunevals
% is reached, or until 1e8 * DIM fevals are conducted. 

opts.popSize = max(2, min(maxfunevals - 20*DIM, 10*DIM)); % TODO test how to set this
opts.lowerBound = ones(1, DIM) * -5;
opts.upperBound = ones(1, DIM) * 5;

opts.doe.n = 20*DIM; % TODO test how to set this
opts.doe.minTolX = 0.002;

opts.sampler.minTolX = 0.002;

% fgeneric takes D-by-n matrices, we work with n-by-D;
opts.eval.handle = @(x)( feval(FUN, x')' );

rescaleConds = {@stopTolX, @stopTolXDistRatio};
opts.rescale = {
  struct('tolerance', 0.05),
  struct('tolerance', 0.5)
};

restartConds = {@stopStallGen};
opts.restart = {
  struct('generations', 5);
};

stopConds = {@stopTotEvals, @stopTargetReached};
opts.stop = {
  struct('evaluations', maxfunevals),
  struct('target', ftarget)
};

gpedaStep2d_ftarget = @(run) gpedaStep2d(run, fgeneric('ftarget'));

xbest = gpeda(opts, @evalHandle, @doeRandom, @sampleGibbs, ...
              rescaleConds, restartConds, stopConds, gpedaStep2d_ftarget);
