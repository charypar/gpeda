function [x, ilaunch] = opt_fminsearch(FUN, DIM, ftarget, maxfunevals)
% minimizes FUN in DIM dimensions by multistarts of fminsearch.
% ftarget and maxfunevals are additional external termination conditions,
% where at most 2 * maxfunevals function evaluations are conducted.
% fminsearch was modified to take as input variable usual_delta to
% generate the first simplex.
% set options, make sure we always terminate
% with restarts up to 2*maxfunevals are allowed

options = optimset('MaxFunEvals', min(1e8*DIM, maxfunevals), ...
  'MaxIter', 2e3*DIM, ...
  'Tolfun', 1e-11, ...
  'TolX', 1e-11, ...
  'OutputFcn', @callback, ...
  'Display', 'off');
% set initial conditions
xstart = 8 * rand(DIM, 1) - 4; % random start solution
usual_delta = 2;
% refining multistarts
for ilaunch = 1:1e4; % up to 1e4 times
  % % try fminsearch from Matlab, modified to take usual_delta as arg
  % x = fminsearch_mod(FUN, xstart, usual_delta, options);
  % standard fminsearch()
  x = fminsearch(FUN, xstart, options);
  % terminate if ftarget or maxfunevals reached
  if (feval(FUN, 'fbest') < ftarget || ...
      feval(FUN, 'evaluations') >= maxfunevals)
    break;
  end
  % terminate with some probability
  if rand(1,1) > 0.90/sqrt(ilaunch)
    break;
  end
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
