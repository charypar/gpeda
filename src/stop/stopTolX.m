function tf = stopTolX(run, opts)

tol = opts.tolerance;

xbest = run.attempts{run.attempt}.bests.x;
dim = size(xbest, 2);

if(size(xbest,1) < 5)
  tf = 0;
  return;
end

a = [xbest(end-4:5, :); zeros(1, dim)];
b = [zeros(1, dim); xbest(end-4:5, :)];

d = sqrt(sum((a - b).^2, 2));
d = d(2:end-1);

tf = sum(d) < opts.tolerance
