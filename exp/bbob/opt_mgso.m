function [x, ilaunch, y_evals, stopflag] = opt_mgso(FUN, dim, ftarget, maxfunevals, id)
% minimizes FUN in DIM dimensions by multistarts of fminsearch.
% ftarget and maxfunevals are additional external termination conditions,
% where at most 2 * maxfunevals function evaluations are conducted.
% fminsearch was modified to take as input variable usual_delta to
% generate the first simplex.
% set options, make sure we always terminate
% with restarts up to 2*maxfunevals are allowed

% Be aware: 'id' is an additional parameter!

% xstart = 8 * rand(dim, 1) - 4; % random start solution

% BBOB defaults
lb     = -5 * ones(dim, 1);
ub     =  5 * ones(dim, 1);
fDelta = 1e-8;

y_evals  = [];
stopflag = [];

load('params.mat', 'bbParamDef', 'sgParamDef');
[bbParams, sgParams] = getParamsFromIndex(id, bbParamDef, sgParamDef, {});

% refining multistarts
for ilaunch = 1:1e4; % up to 1e4 times
  % Info about tested function is for debugging purposes
  bbob_handlesF = benchmarks('handles');
  sgParams.modelOpts.bbob_func = bbob_handlesF{bbParams.functions(1)};
  sgParams.expFileID = [num2str(bbParams.functions(1)) '_' num2str(dim) 'D_' num2str(id)];
  % DEBUG: generate data for testing model regresssion
  % TODO: comment this line! :)
  % sgParams.saveModelTrainingData = [ 10 25 50 100 200 300 470 700 900 1200 1500 2000 2400 ];

  % Transformation of the input parameters

  % 1) task-dependent settings
  opts.popSize = eval(sgParams.popSize);
  opts.lowerBound = lb';
  opts.upperBound = ub';
  % 2) Gaussian process' related settings
  opts.trainAlgorithm = sgParams.modelOpts.trainAlgorithm;
  if (iscell(sgParams.modelOpts.covFunc))
    sgParams.modelOpts.covFunc = {sgParams.modelOpts.covFunc};
  end
  opts.model   = modelInit(dim, sgParams.modelOpts.hyp, sgParams.modelOpts.meanFunc, sgParams.modelOpts.covFunc);
  % 3) DOE (Design of Experiments)
  opts.doe.n = eval(sgParams.doe_n);
  opts.doe.minTolX = sgParams.doe_minTolX;
  % 4) SAMPLER
  opts.sampler.minTolX = sgParams.sampler_minTolX;
  % 5) objective function
  opts.eval.handle = @(x)( feval(FUN, x')' );
  % 6) MGSO-related specific parameters
  opts.rescale = cellMap(sgParams.rescaleCondsParams, @evalStructure);
  opts.restart = cellMap(sgParams.restartCondsParams, @evalStructure);
  opts.stop    = cellMap(sgParams.stopCondsParams, @evalStructure);
  observer     = myeval(sgParams.observer);
  
  % MGSO itself
  [x, runInfo] = gpeda(opts, sgParams.evalHandle, sgParams.doeHandle, sgParams.sampleHandle, ...
              sgParams.rescaleConds, sgParams.restartConds, sgParams.stopConds, observer);

  % save the optimization progress
  bestsY        = [];
  evaluations   = [];
  nEval = 0;
  for att = 1:runInfo.attempt
    bestsY = [bestsY; runInfo.attempts{att}.bests.yms2(:,1)];
    evaluations = [evaluations; runInfo.attempts{att}.bests.evaluations + nEval];
    nEval = nEval + runInfo.attempts{att}.evaluations;
  end
  y_eval = [bestsY, evaluations];

  % [x fmin counteval stopflag out bestever y_eval] = s_cmaes(FUN, xstart, 8/3, cmOptions, 'SurrogateOptions', sgParams);

  n_y_evals = size(y_eval,1);
  y_eval(:,1) = y_eval(:,1) - (ftarget - fDelta) * ones(n_y_evals,1);
  y_evals = [y_evals; y_eval];
  % terminate if ftarget or maxfunevals reached
  if (feval(FUN, 'fbest') < ftarget || ...
      feval(FUN, 'evaluations') >= maxfunevals)
    break;
  end
  % % terminate with some probability
  % if rand(1,1) > 0.98/sqrt(ilaunch)
  %   break;
  % end
  xstart = x; % try to improve found solution
  % % we do not use usual_delta :/
  % usual_delta = 0.1 * 0.1^rand(1,1); % with small "radius"
  % if useful, modify more options here for next launch
end

  function stop = callback(x, optimValues, state)
    stop = false;
    if optimValues.fval < ftarget
      stop = true;
    end
  end % function callback

  function res = evalStructure(s)
    for fname = fieldnames(s)'
      res.(fname{1}) = myeval(s.(fname{1}));
    end
  end

end % function
