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
x_grid = linspace(lb(1), ub(1), gridSize)';
y_grid = linspace(lb(2), ub(2), gridSize)';
[xx, yy] = meshgrid(x_grid, y_grid);
n_points = prod(size(xx));
xy_column = zeros(n_points, 2);
xy_column(:,1) = reshape(xx, n_points, 1);
xy_column(:,2) = reshape(yy, n_points, 1);

[m s2] = modelPredict(M, xy_column);

poi = modelGetPOI(M, xy_column, run.options.sampler.target);

% plot the surface of mean/prediction and error contour lines
subplot(1,2,1);
hold off;
plotErr2(xy_column, m, s2, ds.x, ds.y);

% hold on;
subplot(1,2,2);
[~, sf] = contour(xx, yy, reshape(poi, gridSize, gridSize));
colorbar();
hold on;
% plot([lb ub], run.options.sampler.target * [1 1], 'g--');

% scatter3(pop(:,1), pop(:,2), zeros(1, length(pop)), 'ro');
scatter(pop(:,1), pop(:,2), 'ro');

scatter(best.x(end, 1), best.x(end,2), 'bo');
hold off;

pause;
