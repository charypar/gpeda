function [xyColumn xMatrix yMatrix] = grid2d(lb, ub, gridSize)
% grid2d() - generates 2D grid for ploting 3D plots of functions
%
% lb, ub        - vectors of lower and upper bounds
% gridSize      - the number of points to generate in each dimension
% RETURNS:
% xyColumn      - 2-column matrix (of size [gridSize^2 2]) of all the x/y values
% xMatrix, yMatrix - 2D matrices of size [gridSize gridSize] with values
%                 for respective coordinates

x_grid = linspace(lb(1), ub(1), gridSize)';
y_grid = linspace(lb(2), ub(2), gridSize)';
[xMatrix, yMatrix] = meshgrid(x_grid, y_grid);
n_points = prod(size(xMatrix));
xyColumn = zeros(n_points, 2);
xyColumn(:,1) = reshape(xMatrix, n_points, 1);
xyColumn(:,2) = reshape(yMatrix, n_points, 1);

