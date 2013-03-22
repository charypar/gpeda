function gpedaStep1d(run)

att = run.attempt;
it = run.attempts{att}.iterations;

ds = run.attempts{att}.dataset;
M = run.attempts{att}.model;
scale = run.attempts{att}.scale;
shift = run.attempts{att}.shift;
pop = run.attempts{att}.populations{end};

ev = sum(cell2mat(cellMap(run.attempts, @(att) ( att.evaluations ))));

best = run.attempts{att}.bests;

lb = run.options.lowerBound;
ub = run.options.upperBound;

z = linspace(-1, 1, 501)';
[m s2] = modelPredict(M, z);

poi = modelGetPOI(M, z, run.options.sampler.target);

x = ds.x .* repmat(scale, size(ds.x, 1), 1) + repmat(shift, size(ds.x, 1), 1);
y = ds.y 

plotErr1(linspace(lb, ub, 501)', m, s2, x, y);

hold on;
plot(linspace(lb, ub, 501)', poi, 'g-')
plot([lb ub], run.options.sampler.target * [1 1], 'g--');

pop = pop .* repmat(scale, size(pop, 1), 1) + repmat(shift, size(pop, 1), 1);
plot(pop, zeros(1, length(pop)), 'rx');

bestx = best.x(end, :) .* scale + shift;
besty = best.yms2(end, 1) .* scale + shift;
plot(bestx, besty, 'or');

hold off;

t = sprintf('Attempt %d, generation %d (used %d evaluations)', att, it, ev);
title(t);

disp('Press any key to continue...');
pause;
