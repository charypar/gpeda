function gpedaStep1d(run)

att = run.attempt;
it = run.attempts{att}.iterations;

ds = run.attempts{att}.dataset;
M = run.attempts{att}.model;
pop = run.attempts{att}.populations{it};

best = run.attempts{att}.bests;

lb = run.options.lowerBound;
ub = run.options.upperBound;

z = linspace(lb, ub, 501)';
[m s2] = modelPredict(M, z);

poi = modelGetPOI(M, z, run.options.sampler.target);


plotErr1(z, m, s2, ds.x, ds.y);

hold on;
plot(z, poi, 'g-')
plot([lb ub], run.options.sampler.target * [1 1], 'g--');

plot(pop, zeros(1, length(pop)), 'rx');

plot(best.x(end, :), best.yms2(end, 1), 'or');
hold off;

pause;
