function [xopt varargout] = gpeda(options, eval, doe, sampler, rescale, restart, stop, varargin)
% Gausian Process based variation of estimation of distribution algorithm (EDA). Performs a
% heuristic optimization run.
%
% options - struct with the following fields:
%           popSize    - population size for each iteration
%           lowerBound - lower bound of the search (piece-wise)
%           upperBound - upper bound of the search
%           model      - custom model (see modelInit)
%           eval       - evaluation strategy options
%           doe        - initial design of experiment
%           sampler    - sampling strategy options
%           stop       - stop conditions options
% eval    - evaluation strategy (function handle)
% doe     - initial design of experiment (function handle)
% sampler - sampling strategy (function handle or cell array of function handles)
% restart - restart conditions (function handle or cell array of function handles), e.g. stall
% stop    - termination conditions (function handle or cell array of function handles), e.g. 
%   evaluation budget depleted
% 
% As an pptional argument you can pass in a function handle that will be called in each iteration with
% the current state of the run. You can use this to observe and debug the run.
%
% Some of the strategies (sampling, restart & stop conditions) can have composite structure: multiple
% function handles in a cell array. In that case they are used together (reduced with set union for
% sampling and logical or for stop/restart conditions). Respective field in the options struct should 
% also be cell arrays containing individual options structs for each part of the composite strategy.
%
% Return values can be:
% [xopt    ] = gpeda(...)
% [xopt run] = gpeda(...)
% where:
% xopt - the optimal input found
% run  - struct containing various statistics about the whole optimization run, including the dataset,
%   individual populations and predictions

maxTrainErrors = 8;
% FIXME: add it to options!

lb = options.lowerBound(:)';
ub = options.upperBound(:)';
n  = options.popSize;
dim = length(lb);

run.options = options;

run.attempt = 1;
run.attempts = {};
run.notSPDCovarianceErrors = [];

att = 1;
run.attempts{att} = initAttempt(lb, ub, options);
pop = [];

disp(sprintf('\n ==== Starting new optimization run ==== \n'));
doRestart = 0; doRescale = 0;

while ~evalconds(stop, run, options.stop) % until one of the stop conditions occurs
  att = run.attempt;
  it = run.attempts{att}.iterations;
  ds = run.attempts{att}.dataset;
  M = run.attempts{att}.model;
  scale = run.attempts{att}.scale;
  shift = run.attempts{att}.shift;
  pop = []; tolXDistRatio = 0;

  disp(sprintf('\n-- Attempt %d, iteration %d --', att, it));

  % train model
  disp(['Training model...']);
  [M_try nErrors] = modelTrain(M, ds.x, ds.y);
  run.notSPDCovarianceErrors = [run.notSPDCovarianceErrors nErrors];

  if (nErrors > maxTrainErrors) 
    disp('Too many errors while training model. Find and evaluate minimum of the GP model.');
    if (~isfield(run.attempts{att}.model, 'dataset'))
      M = M_try;
    end
    gp_predict = @(x_gp) modelPredict(M, x_gp);
    % % this is GADS Toolbox, which we dont have license for :(
    %{
    got_opts = optimset('Algorithm', 'interior-point');
    problem = createOptimProblem('fmincon', 'objective',... 
      gp_predict,'x0',run.attempts{att}.bests.x(end,:),'lb',-1,'ub',1,'options',got_opts);
    gs = GlobalSearch;
    [minimum,fval] = run(gs, problem);
    %}

    % this is Matlab core fminsearch() implementation
    fminoptions = optimset('MaxFunEvals', min(1e6*dim), ...
      'MaxIter', 1000*dim, ...
      'Tolfun', 1e-7, ...
      'TolX', 1e-7, ...
      'Display', 'off');
    pop = fminsearch(gp_predict, run.attempts{att}.bests.x(end,:), fminoptions);

    if (length(run.notSPDCovarianceErrors) > 1  &&  run.notSPDCovarianceErrors(end-1) > maxTrainErrors)
      % do restart, because last rescale didn't help
      disp('--> 2nd time! Restart.');
      doRestart = 1; doRescale = 0;
    else  % if (nErrors > maxTrainErrors) 
      % first train error, do rescale
      disp('--> 1st time, do rescale and we will see.');
      doRescale = 1; doRestart = 0;
    end
  else
    % sample new population
    M = M_try;
    run.attempts{att}.model = M;
    disp(['Sampling population ' int2str(it) '...']);
    try
      [pop tolXDistRatio] = sample(sampler, M, dim, options.popSize, run.attempts{att}, options.sampler);
    catch err
      disp(['Sample error: ' err.identifier]);
      disp(getReport(err));
      if strcmp(err.identifier, 'sampleGibbs:NarrowDataset')
        doRestart = 1;
        fprintf('  NarrowDataset: size(pop) = %s; tolXDistRatio = %f\n', num2str(size(pop)), tolXDistRatio);
      end
      if strcmp(err.identifier, 'sampleGibbs:CovarianceMatrixNotSPD')
        doRestart = 1; fprintf(err.message);
      end
      if strcmp(err.identifier, 'sampleGibbs:NarrowProbability')
        doRescale = 1;
        fprintf('  NarrowProbability: size(pop) = %s; tolXDistRatio = %f\n', num2str(size(pop)), tolXDistRatio);
      end
      if strcmp(err.identifier, 'sampleGibbs:NoProbability')
        doRestart = 1;
        fprintf('  NoProbability. Restart.\n');
      end
    end
  end

  % if there are at least some individuals returned from sampler(s)
  if (exist('pop', 'var') && ~isempty(pop))

    run.attempts{att}.populations{it} = pop;
    run.attempts{att}.tolXDistRatios(it) = tolXDistRatio;

    run.attempts{att}.model = M;
    if nargin > 7 && isa(varargin{1}, 'function_handle')
      feval(varargin{1}, run)
    end

    % evaluate and add to dataset
    disp(['Evaluating ' num2str(size(pop, 1)) ' new individuals']);

    [m s2] = modelPredict(M, pop);

    x = transform(pop, scale, shift);
    y = feval(eval, x, m, s2, options.eval);

    run.attempts{att}.evaluations = run.attempts{att}.evaluations + length(y);

    % store the best so far
    [ymin i] = min(y);
    if size(run.attempts{att}.bests.yms2, 1) < 1 || ymin < run.attempts{att}.bests.yms2(end, 1)
      % record improved solution
      ev = run.attempts{att}.evaluations;
      fprintf('Best solution improved to f(%s) = %s. (used %d evaluations in this attempt)\n', num2str(pop(i,:)), num2str(ymin), ev);
      run.attempts{att}.bests.x(end + 1, :) = pop(i, :);
      run.attempts{att}.bests.yms2(end + 1, :) = [y(i) m(i) s2(i)];
    else
      disp(['Best solution did not improve']);
      % record unbeaten last solution
      run.attempts{att}.bests.x(end + 1, :) = run.attempts{att}.bests.x(end, :);
      run.attempts{att}.bests.yms2(end + 1, :) = run.attempts{att}.bests.yms2(end, :);
    end

    % add new samples to the dataset for next iteration
    disp(['Augmenting dataset']);
    run.attempts{att}.dataset.x = [ds.x; pop];
    run.attempts{att}.dataset.y = [ds.y; y];

    % and we've completed an iteration
    run.attempts{att}.iterations = run.attempts{att}.iterations + 1;

  else
    disp('Warning: pop is empty!');
  end   % if (exist('pop') && ~isempty(pop))

  % if one of the restart conditions occurs
  if doRestart || (isfield(options, 'restart') && evalconds(restart, run, options.restart))
    disp(['Restart conditions met, starting over...']);
    run.attempt = run.attempt + 1;
    att = run.attempt;
  
    % initialize new attempt
    run.attempts{att} = initAttempt(lb, ub, options);
    run.notSPDCovarianceErrors = [];
    doRestart = 0;
  else
    if doRescale ...
      || isfield(options, 'rescale') && evalconds(rescale, run, options.rescale)
      [nlb nub] = computeRescaleLimits(run.attempts{att}, dim);

      if (min(abs([nlb nub])) > .8)
        % cancel rescale, we have new limits [-1 -1 ... -1] / [1 1 ... 1]
        disp('Rescaling conditions DID NOT met, limits [-1..-1] / [1..1]'); 
        disp('Do restart. There is something wrong in the dataset.'); 
        doRestart = 1;
      else
        if (run.attempts{att}.iterations > 1)
          disp('Rescaling conditions met, zooming in...');
          run.attempts{att}.rescaleFlag = 1;
          run.attempt = run.attempt + 1;
          att = run.attempt;

          run.attempts{att} = initRescaleAttempt(run.attempts{att-1}, nlb, nub, options);
          disp('Got rescale attempt');
          run.attempts{att}
        else
          disp('Rescaling canceled, rescale was already in the last attempt.');
        end
      end
      doRescale = 0;
    end
  end

end

% return the best overall

besty = cell2mat(cellMap(run.attempts, @(attempt)( attempt.bests.yms2(end, 1) )));
bestx = cell2mat(cellMap(run.attempts, @(attempt)( attempt.bests.x(end, :)' )))';
scales = cell2mat(cellMap(run.attempts, @(attempt)( attempt.scale )));
shifts = cell2mat(cellMap(run.attempts, @(attempt)( attempt.shift )));

[yopt iopt] = min(besty)
xopt = transform(bestx(iopt,:), scales(iopt), shifts(iopt));

if nargout > 0
  varargout{1} = run;
end

% Support functions

function attempt = initAttempt(lb, ub, options)
  D = length(lb);

  if(isfield(options, 'model'))
    attempt.model = options.model;
  else
    attempt.model = modelInit(D);
  end

  attempt.iterations = 1;
  attempt.scale = (ub - lb) / (1 + 1);
  attempt.shift = -1 - (lb ./ attempt.scale);

  % generate initial dataset
  attempt.dataset.x = feval(doe, D, options.doe);

  dsx = attempt.dataset.x;
  dsx = transform(dsx, attempt.scale, attempt.shift);
  
  attempt.dataset.y = feval(eval, dsx, [], [], options.eval);
  attempt.evaluations = length(attempt.dataset.y);
  
  % FIXME assumes mean function is a constant
  ymean = mean(attempt.dataset.y);
  attempt.model.hyp.mean = ymean;

  attempt.populations = {};
  attempt.tolXDistRatios = [1];
  attempt.rescaleFlag = 0;

  [ym, im] = min(attempt.dataset.y);
  attempt.bests.x = attempt.dataset.x(im,:);    % a matrix with best input vectors rows 
  attempt.bests.yms2 = [ym 0 0]; % a matrix with rows [y m s2] for the best individual in each generation
end

function attempt = initRescaleAttempt(lastAttempt, lb, ub, options)
  D = length(lb);

  if(isfield(options, 'model'))
    attempt.model = options.model;
  else
    attempt.model = modelInit(D);
  end

  lastScale = lastAttempt.scale;
  lastShift = lastAttempt.shift;

  attempt.iterations = 1;
  oub = transform(ub, lastScale, lastShift);
  olb = transform(lb, lastScale, lastShift);

  attempt.scale = (oub - olb) / 2;
  %attempt.shift = -(olb + oub) / 2;
  attempt.shift = -1 - (olb ./ attempt.scale);

  % generate initial dataset
  [fx fy] = filterDataset(lastAttempt.dataset, lb, ub);
  scaleDataset = (ub - lb) / (1 + 1);
  shiftDataset = -1 - (lb ./ scaleDataset);
  attempt.dataset.x = inv_transform(fx, scaleDataset, shiftDataset);
  attempt.dataset.y = fy;

  % FIXME assumes mean function is a constant
  ymean = mean(fy);
  attempt.model.hyp.mean = ymean;

  attempt.evaluations = 0;
  
  attempt.populations = {};
  attempt.tolXDistRatios = [1];

  [ym, im] = min(attempt.dataset.y);
  attempt.bests.x = attempt.dataset.x(im,:);    % a matrix with best input vectors rows 
  attempt.bests.yms2 = [ym 0 0]; % a matrix with rows [y m s2] for the best individual in each generation
end

function tf = evalconds(conds, run, opts)
  if isa(conds, 'function_handle')
    tf = feval(conds, run, opts);
  else
    for k = 1:length(conds)
      conds{k} = feval(conds{k}, run, opts{k});
    end
    tf = cellReduce(conds, @(r, in) ( r || in ), 0);
  end
end

function [pop tol] = sample(samplers, M, D, n, thisAttempt, opts)
  if isa(samplers, 'function_handle')
    [pop tol] = feval(samplers, M, D, n, thisAttempt, opts);
  else
    for k = 1:length(samplers)
      [p t] = feval(samplers{k}, M, D, n, thisAttempt, opts{k});
      samplers{k} = [p t];
    end
    pop = cellReduce(samplers, @(r, in) ( [r; in] ), []);
    tol = cellReduce(samplers, @(r, in) ( min(r, in) ), 1);
  end
end

function [lb ub] = computeRescaleLimits(attempt, dim)
  dsx = attempt.dataset.x;
  dsxopt = repmat(attempt.bests.x(end, :), size(dsx, 1), 1);

  disp('Rescaling dataset fired, computing new limits.');

  % compute distances from the current optimum
  dist = sqrt(sum((dsxopt - dsx).^2, 2));
  [~, ind] = sort(dist);

  % take 10*D closest points
  if(length(ind) > 10*dim)
    besti = ind(1:10*dim);
  else
    warning('Rescaling did not discard any points');
    besti = ind;
  end

  dsx = dsx(besti, :);

  % take extremes
  lb = min(dsx);
  ub = max(dsx);

  % extend the extremes
  dif = ub - lb;
  lb = lb - 0.05*dif;
  ub = ub + 0.05*dif;
  
  lb = max([lb; -1*ones(1, dim)]);
  ub = min([ub; 1*ones(1, dim)]);

  disp(['New bounds: ' num2str(lb) ' ' num2str(ub)]);
end

function [x y] = filterDataset(ds, lob, upb)
  alb = all(ds.x > repmat(lob, size(ds.x, 1), 1), 2);
  bub = all(ds.x < repmat(upb, size(ds.x, 1), 1), 2);

  ind = and(alb, bub);

  x = ds.x(ind, :);
  y = ds.y(ind, :);
end

end
