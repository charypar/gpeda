function gpedaStep2d(run, varargin)

att = run.attempt;
it = run.attempts{att}.iterations;

ds = run.attempts{att}.dataset;
M = run.attempts{att}.model;
pop = run.attempts{att}.populations{it};

best = run.attempts{att}.bests;

scale = run.attempts{att}.scale;
shift = run.attempts{att}.shift;

lb = run.options.lowerBound;
ub = run.options.upperBound;

% assert(max(size(lb)) == 2, 'gpedaStep2d(): Input dimensions is not 2D.');

if (nargin > 1)
  disp(['Best so-far: ' num2str(best.yms2(end,1)) '   delta = ' num2str(best.yms2(end,1)-varargin{1})]);
end

gridSize = 101;
[xy_column xx yy] = grid2d([-1 -1], [1 1], gridSize);

dim = size(lb,2);
if (dim > 2)
  xy_column = [xy_column zeros(size(xy_column,1),dim-2)];
end

xy_original = transform(xy_column, scale, shift);

n = sqrt(size(xy_original, 1));
xx_o = reshape(xy_original(:, 1), n, n); 
yy_o = reshape(xy_original(:, 2), n, n); 

[m s2] = modelPredict(M, xy_column);
% poi = modelGetPOI(M, xy_column, run.options.stop{2}.target);
poi = modelGetPOI(M, xy_column, run.attempts{end}.bests.yms2(end,1));

att = run.attempt;
it = run.attempts{att}.iterations;
ev = sum(cell2mat(cellMap(run.attempts, @(att) ( att.evaluations ))));

disp(['Evaluations so far: ' num2str(ev)]);

t = sprintf('Attempt %d, generation %d (used %d evaluations)', att, it, ev);
title(t);

% plot the surface of mean/prediction and error contour lines
subplot(1,2,1);
hold off;
dsx = transform(ds.x, scale, shift);
plotErr2(xy_original(:,1:2), m, s2, dsx(:,1:2), ds.y);
title('Model and dataset');

% hold on;
subplot(1,2,2);
[~, sf] = contour(xx_o, yy_o, reshape(poi, gridSize, gridSize));
title('Probability of improvement');
colorbar();
hold on;
% plot([lb ub], run.options.sampler.target * [1 1], 'g--');

% scatter3(pop(:,1), pop(:,2), zeros(1, length(pop)), 'ro');
pop = transform(pop, scale, shift);
scatter(pop(:,1), pop(:,2), 'ro');
% the last point returned by the Gibbs sampler has highest POI, mark it with blue *
scatter(pop(end,1), pop(end,2), 'b*');

bestx = transform(best.x, scale, shift);
scatter(bestx(end, 1), bestx(end,2), 'bo');

hold off;

pause(1);
