function tf = stopStallGen(run, opts)
% Stop after target did not improve for opts.generations generations

yms2 = run.attempts{run.attempt}.bests.yms2;
g = opts.generations;

if size(yms2, 1) < g
  tf = 0;
  return;
end

lastn = yms2(end-g+1:end, 1);
tf = (min(lastn) == max(lastn));
