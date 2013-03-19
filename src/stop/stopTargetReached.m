function tf = stopTargetReached(run, opts)
% Stop when a given target is reached

yms2 = run.attempts{run.attempt}.bests.yms2;

tf = length(yms2) > 0 && yms2(end, 1) <= opts.target;
