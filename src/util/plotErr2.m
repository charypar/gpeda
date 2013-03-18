function plotErr2(x, m, s2, xt, yt)
% plot a function with 95% confidence region.
%
% x  - inputs
% m  - mean predictions
% s2 - prediction errors
% xt - optional: training inputs
% yt - optional: training outputs

n = sqrt(size(x,1));
xMatrix = reshape(x(:,1),n,n);
yMatrix = reshape(x(:,2),n,n);
mMatrix = reshape(m,n,n);
s2Matrix = reshape(s2,n,n);

% meshgrid of the prediction
sf = mesh(xMatrix, yMatrix, mMatrix);
set(sf, 'FaceColor', 'none');
hold on;

% coutours of the error-bounds
[~, sf] = contour3(xMatrix, yMatrix, mMatrix+2*sqrt(s2Matrix)); % , 'LineColor', 'red');
set(sf,'EdgeColor','red')
% % lower bounds...
% [~, sf] = contour3(xMatrix, yMatrix, mMatrix-2*sqrt(s2Matrix)); % , 'LineColor', 'red');
% set(sf,'EdgeColor','blue')

% plot of the dataset
if nargin == 5
  hold on;
  scatter3(xt(:,1), xt(:,2), yt, 'filled');
end
