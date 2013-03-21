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

lb = options.lowerBound;
ub = options.upperBound;
n  = options.popSize;
dim = length(lb);

run.options = options;

run.attempt = 1;
run.attempts = {};

att = 1;
run.attempts{att} = initAttempt(lb, ub);

while ~evalconds(stop, run, options.stop) % until one of the stop conditions occurs
  att = run.attempt;
  it = run.attempts{att}.iterations;
  ds = run.attempts{att}.dataset;
  M = run.attempts{att}.model;
  scale = run.attempts{att}.scale;
  shift = run.attempts{att}.shift;

  disp(sprintf('\n-- Attempt %d, iteration %d --', att, it));

  % train model
  disp(['Training model...']);
  M = modelTrain(M, ds.x, ds.y);
  % M.hyp.lik = max(M.hyp.lik, log(0.0001)); % bound sn to prevent numerical errors
  run.attempts{att}.model = M;

  % sample new population
  disp(['Sampling population ' int2str(it) '...']);
  try
    cannot_sample = 0;
    [pop tolXDistRatio] = sample(sampler, M, dim, options.popSize, run.attempts{att}, options.sampler);
  catch
    disp(['Could not sample any points, giving up: ' lasterr]);
    cannot_sample = 1;
  end
  run.attempts{att}.populations{it} = pop;
  run.attempts{att}.tolXDistRatios{it} = tolXDistRatio;

  if nargin > 6 && isa(varargin{1}, 'function_handle')
    feval(varargin{1}, run)
  end

  if cannot_sample
    break; % FIXME what do we do now?? If there is no POI for the first time, rescale
  end

  % evaluate and add to dataset
  disp(['Evaluating ' num2str(size(pop, 1)) ' new individuals']);

  x = pop .* repmat(scale, size(pop, 1), 1) + repmat(shift, size(pop, 1), 1);
  [m s2] = modelPredict(M, pop);

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

  if isfield(options, 'rescale') && evalconds(rescale, run, options.rescale)
    run.attempt = run.attempt + 1;
    att = run.attempt;
    
    [nlb nub] = computeRescaleLimits(run.attempts{att-1});
    run.attempts{att} = initRescaleAttempt(nlb, nub);
  end

  % if one of the restart conditions occurs
  if isfield(options, 'restart') && evalconds(restart, run, options.restart) 
    disp(['Restart conditions met, starting over...']);
    run.attempt = run.attempt + 1;
    att = run.attempt;
  
    % initialize new attempt
    run.attempts{att} = initAttempt(lb, ub);
  end
end

% return the best overall

besty = cell2mat(cellMap(run.attempts, @(attempt)( attempt.bests.yms2(end, 1) )));
bestx = cell2mat(cellMap(run.attempts, @(attempt)( attempt.bests.x(end, :)' )))';

[yopt iopt] = min(besty)
xopt = bestx(iopt, :); % TODO rescale output back to original space

if nargout > 0
  varargout{1} = run;
end

% Support functions

function attempt = initAttempt(lb, ub)
  dim = length(lb);

  if(isfield(options, 'model'))
    attempt.model = options.model;
  else
    attempt.model = modelInit(dim);
  end

  attempt.iterations = 1;
  attempt.scale = (ub - lb)/2;
  attempt.shift = (lb + ub)/2;

  % generate initial dataset
  attempt.dataset.x = feval(doe, dim, options.doe);

  x = attempt.dataset.x;
  x = x .* repmat(attempt.scale, size(x, 1), 1) + repmat(attempt.shift, size(x, 1), 1);
  
  attempt.dataset.y = feval(eval, x, [], [], options.eval);
  attempt.evaluations = length(attempt.dataset.y);
  
  attempt.populations = {};

  [ym, im] = min(attempt.dataset.y);
  attempt.bests.x = attempt.dataset.x(im,:);    % a matrix with best input vectors rows 
  attempt.bests.yms2 = [ym 0 0]; % a matrix with rows [y m s2] for the best individual in each generation
end

function tf = evalconds(conds, run, opts)
  if isa(conds, 'function_handle')
    tf = feval(conds, run, opts);
  else
    for i = 1:length(conds)
      conds{i} = feval(conds{i}, run, opts{i});
    end
    tf = cellReduce(conds, @(r, in) ( r || in ), 0);
  end
end

function [pop tol] = sample(samplers, M, D, n, thisAttempt, opts)
  if isa(samplers, 'function_handle')
    [pop tol] = feval(samplers, M, D, n, thisAttempt, opts);
  else
    for i = 1:length(samplers)
      [p t] = feval(samplers{i}, M, D, n, thisAttempt, opts{i});
      samplers{i} = [p t];
    end
    pop = cellReduce(samplers, @(r, in) ( [r; in] ), []);
    tol = cellReduce(samplers, @(r, in) ( min(r, in) ), 1);
  end
end

end
