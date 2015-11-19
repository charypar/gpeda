function tf = stopSmallPopulations(run, opts)
% Stop after target did not improve for opts.generations generations

popSizes = run.attempts{run.attempt}.popSize;
limit = opts.popSizeLimit;
n     = opts.iterationsLimit;

tf = 0;

if (length(popSizes) > n  &&  all(popSizes < limit))
  tf = 1;
end