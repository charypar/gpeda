function gpedaStep1d(run)

att = run.attempt;
it = run.attempts{att}.iterations;

ds = run.attempts{att}.dataset;
M = run.attempts{att}.model;
scale = run.attempts{att}.scale
shift = run.attempts{att}.shift
pop = run.attempts{att}.populations{end};

ev = sum(cell2mat(cellMap(run.attempts, @(att) ( att.evaluations ))));

best = run.attempts{att}.bests;

lb = run.options.lowerBound;
ub = run.options.upperBound;

z = linspace(-1, 1, 501)';
[m s2] = modelPredict(M, z);
poi = modelGetPOI(M, z, run.options.sampler.target);

x = transform(ds.x, scale, shift);
y = ds.y;

plotz = transform(linspace(-1, 1, 501)', scale, shift);
plotErr1(plotz, m, s2, x, y);

hold on;
plot(plotz, poi, 'g-')
plot(transform([-1 1]', scale, shift)', run.options.sampler.target * [1 1], 'g--');

pop = transform(pop, scale, shift);
plot(pop, zeros(1, length(pop)), 'rx');

bestx = transform(best.x(end, :), scale, shift);
besty = best.yms2(end, 1);
plot(bestx, besty, 'or');

hold off;

t = sprintf('Attempt %d, generation %d (used %d evaluations)', att, it, ev);
title(t);

disp('Press any key to continue...');
pause;
