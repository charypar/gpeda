function x = doeRandom(lb, ub, options)
% Random design of experiment. Selects n random points uniformly distributed between lower
% bound lb and upper bound ub. Options are unused.

% ensure row vectors
lb = lb(:)';
ub = ub(:)';

dif = ub - lb;
D = length(dif);
n = options.n;

x = ones(n, 1) * lb + rand(n, D) .* (ones(n, 1) * dif);
