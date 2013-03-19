function tf = stopStallGen(run, opts)
% Stop after target did not improve for opts.generations generations

yms2 = run.attempts{run.attempt}.bests.yms2;
g = opts.generations;

tf = size(yms2, 1) >= g && range(yms2(end-g+1:end, 1)) == 0;
