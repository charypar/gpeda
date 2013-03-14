function tf = stopNEvals(run, opts)
% Stop after a specific number of evaluations

% stop if the next generation would go over the limit
% FIXME this wastes a few evaluations in the end of the experiment, 
% any ideas for fixing are welcome
tf = (run.attempts{run.attempt}.evaluations + run.options.popSize > opts.n)
