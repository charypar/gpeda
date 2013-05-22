function poiContour(M, attempt, varargin)

it = attempt.iterations;
% pop = attempt.populations{it};
if (nargin > 2)
  pop = varargin{1};
else
  pop = [];
end

gridSize = 101;
[xy_column xx yy] = grid2d([-1 -1], [1 1], gridSize);

xy_original = transform(xy_column, attempt.scale, attempt.shift);

n = sqrt(size(xy_original, 1));
xx_o = reshape(xy_original(:, 1), n, n); 
yy_o = reshape(xy_original(:, 2), n, n); 

poi = modelGetPOI(M, xy_column, attempt.bests.yms2(end,1));

[~, sf] = contour(xx_o, yy_o, reshape(poi, gridSize, gridSize));
title('Probability of improvement');
colorbar();
hold on;

if (~isempty(pop))
  pop = transform(pop, attempt.scale, attempt.shift);
  scatter(pop(:,1), pop(:,2), 'ro');
  % the last point returned by the Gibbs sampler has highest POI, mark it with blue *
  scatter(pop(end,1), pop(end,2), 'b*');
end
hold off;

end
