function gpedaStep2d(run)

att = run.attempt;
it = run.attempts{att}.iterations;

ds = run.attempts{att}.dataset;
M = run.attempts{att}.model;
pop = run.attempts{att}.populations{it};

best = run.attempts{att}.bests;

lb = run.options.lowerBound;
ub = run.options.upperBound;

assert(max(size(lb)) == 2, 'gpedaStep2d(): Input dimensions is not 2D.');

gridSize = 101;
[xy_column xx yy] = grid2d([-1 -1], [1 1], gridSize);

[m s2] = modelPredict(M, xy_column);

poi = modelGetPOI(M, xy_column, run.options.sampler.target);

att = run.attempt;
it = run.attempts{att}.iterations;
ev = sum(cell2mat(cellMap(run.attempts, @(att) ( att.evaluations ))));

t = sprintf('Attempt %d, generation %d (used %d evaluations)', att, it, ev);
title(t);

% plot the surface of mean/prediction and error contour lines
subplot(1,2,1);
hold off;
plotErr2(xy_column, m, s2, ds.x, ds.y);
title('Model and dataset');

% hold on;
subplot(1,2,2);
[~, sf] = contour(xx, yy, reshape(poi, gridSize, gridSize));
title('Probability of improvement');
colorbar();
hold on;
% plot([lb ub], run.options.sampler.target * [1 1], 'g--');

% scatter3(pop(:,1), pop(:,2), zeros(1, length(pop)), 'ro');
scatter(pop(:,1), pop(:,2), 'ro');
% the last point returned by the Gibbs sampler has highest POI, mark it with blue *
scatter(pop(end,1), pop(end,2), 'b*');

scatter(best.x(end, 1), best.x(end,2), 'bo');

hold off;

pause(1);
