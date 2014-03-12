function [xbest result] = opt_gpeda_rosenbrock(FUN, DIM, ftarget, maxfunevals)
% MY_OPTIMIZER(FUN, DIM, ftarget, maxfunevals)

% cov_function = 'covSEard';
cov_function = 'covSEiso';

% task dependent settings
popSize = 10 * DIM;
  opts.popSize = max(2, min(maxfunevals - popSize, popSize)); % TODO test how to set this
opts.lowerBound = ones(1, DIM) * -5;
opts.upperBound = ones(1, DIM) * 5;

% GP model training algorithm
opts.trainAlgorithm = 'fmincon';

% DOE
opts.doe.n = popSize            % TODO test how to set this
opts.doe.minTolX = 0.002;

% SAMPLER
opts.sampler.minTolX = 0.002;

% fgeneric takes D-by-n matrices, we work with n-by-D;
opts.eval.handle = @(x)( feval(FUN, x')' );

% Rescale Conditions
rescaleConds = {@stopTolX, @stopTolXDistRatio, @stopLowLogpdf};
opts.rescale = {
  struct('tolerance', 0.1),
  struct('tolerance', 0.5),
  struct('tolerance', log(0.05))
};

% Restart Conditions
restartConds = {@stopStallGen};
opts.restart = {
  struct('generations', 5);
};

% Stop Conditions
stopConds = {@stopTotEvals, @stopTargetReached};
opts.stop = {
  struct('evaluations', maxfunevals),
  struct('target', ftarget)
};

gpedaStep2d_ftarget = @(run) gpedaStep2d(run, fgeneric('ftarget'));

if (strcmpi(cov_function, 'covSEard'))
  hyp.cov = log([0.05 * ones(1,DIM)  0.1]);
  hyp.mean = [0];
  hyp.lik = log(0.001);
  mean = @meanConst;
  cov = @covSEard;
  opts.model = modelInit(DIM, hyp, mean, cov);
elseif (strcmpi(cov_function, 'covSEiso'))
  % % rastrigin
  % hyp.cov = [-2.7 2.6];
  % rosenbrock
  hyp.cov = [0.1 11];
  hyp.mean = [0];
  % % rastrigin
  % hyp.lik = -1.1;
  % rosenbrock
  hyp.lik = -4;
  mean = @meanConst;
  cov = @covSEiso;
  opts.model = modelInit(DIM, hyp, mean, cov);
end

[xbest run] = gpeda(opts, @evalHandle, @doeRandom, @sampleSlice, ...
              rescaleConds, restartConds, stopConds, gpedaStep2d_ftarget);

if (nargout > 1)
  result = struct();
  result.bestsX = [];
  result.bestsY = [];
  result.deltasY = [];
  result.evaluations = [];
  nEval = 0;
  result.optimum = fgeneric('ftarget');
  for att = 1:run.attempt
    result.bestsX = [result.bestsX; run.attempts{att}.bests.x];
    result.bestsY = [result.bestsY; run.attempts{att}.bests.yms2(:,1)];
    result.deltasY = [result.deltasY; run.attempts{att}.bests.yms2(:,1) - result.optimum];
    result.evaluations = [result.evaluations; run.attempts{att}.bests.evaluations + nEval];
    nEval = nEval + run.attempts{att}.evaluations;
  end
end
