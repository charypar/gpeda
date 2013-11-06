function [x, ilaunch, y_evals] = opt_tomlab_ego(FUN, DIM, ftarget, maxfunevals)
% minimizes FUN in DIM dimensions by multistarts of fminsearch.
% ftarget and maxfunevals are additional external termination conditions,
% where at most 2 * maxfunevals function evaluations are conducted.
% fminsearch was modified to take as input variable usual_delta to
% generate the first simplex.
% set options, make sure we always terminate
% with restarts up to 2*maxfunevals are allowed

xstart = 8 * rand(DIM, 1) - 4; % random start solution

x_L = -5 * ones(1,DIM);
x_U = 5 * ones(1,DIM);
x_min = x_L;
x_max = x_U;
tomlabProb = glcAssign(FUN, x_L, x_U, 'BBOB_EGO_test', [], [], [],...
    [], [], [], [], ...
    [], [], [], [], ...
    [], x_min, x_max, [], []);
% Max. number of FUN evaluations
tomlabProb.optParam.MaxFunc = min(1e6*DIM, maxfunevals);
% Max. number of response-surface local optimization iterations
tomlabProb.optParam.MaxIter = 100; % (default: 1000)
% No warm start
tomlabProb.WarmStart = 0;
tomlabProb.MaxCPU = 600;
% Circle surrounding by 20%, ExD = 14
% TODO: to be tuned!!! see `help ego` and Prob.CGO.Percent parameter
tomlabProb.CGO.Percent = 120;
tomlabProb.CGO.nSample = 10*DIM;

y_evals = [];

% refining multistarts
for ilaunch = 1:1e4; % up to 1e4 times
  % % try fminsearch from Matlab, modified to take usual_delta as arg
  % x = fminsearch_mod(FUN, xstart, usual_delta, options);
  % standard fminsearch()
  % [x fmin counteval stopflag out bestever y_eval] = cmaes(FUN, xstart, 8/3, options);
  Result = ego(tomlabProb);
  
  FF = Result.CGO.WarmStartInfo.F00;
  x = Result.x_k;
  y_eval = zeros(length(FF), 2);
  y_eval = [FF(1) 1];
  for i = 2:length(FF)
    y_eval(i,:) = [min(FF((i-1):i)) i];
  end;

  n_y_evals = size(y_eval,1);
  y_eval = y_eval - ([ftarget * ones(n_y_evals,1) zeros(n_y_evals,1)]);
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

end % function
