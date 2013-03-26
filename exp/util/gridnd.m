function [xColumns] = gridnd(lb, ub, gridSize)
% grid2d() - generates 2D grid for ploting 3D plots of functions
%
% lb, ub        - vectors of lower and upper bounds
% gridSize      - the number of points to generate in each dimension
% RETURNS:
% xyColumn      - 2-column matrix (of size [gridSize^2 2]) of all the x/y values
% xMatrix, yMatrix - 2D matrices of size [gridSize gridSize] with values
%                 for respective coordinates

dim = length(lb);

% xColumns = zeros(gridSize^dim,dim);
xColumns = [];

for i = 1:dim
  x_grid = linspace(lb(dim-(i-1)), ub(dim-(i-1)), gridSize)';

  xColumns1 = zeros(gridSize^i,i);
  if (i > 1)
    xColumns1(:,2:end) = repmat(xColumns, gridSize, 1);
  end
  for j = 1:gridSize
    xColumns1(((j-1)*gridSize^(i-1)+1):j*gridSize^(i-1),1) = x_grid(j);
  end

  xColumns = xColumns1;
end

%  [1:dim 1:dim 1:dim 1:dim ..]';
%  [1*ones(dim,1) 2*ones(dim,1) .. 1*ones(dim,1) ..]';

