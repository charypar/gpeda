function tf = stopTotEvals(run, opts)
% Stop after a specific number of evaluations

% stop if the next generation would go over the limit
% FIXME this wastes a few evaluations in the end of the experiment, 
% any ideas for fixing are welcome

total = cellReduce(run.attempts, @(tot, att)( tot + att.evaluations ), 0);

tf = (total + run.options.popSize > opts.evaluations);
