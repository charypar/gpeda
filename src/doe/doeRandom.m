function x = doeRandom(D, options)
% Random design of experiment. Selects n random points uniformly distributed between lower
% bound lb and upper bound ub. Options are unused.

n = options.n;
x = 2 * rand(n, D) - 1;
