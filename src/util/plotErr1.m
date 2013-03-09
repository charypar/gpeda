function plotErr1(x, m, s2, xt, yt)
% plot a function with 95% confidence region.
%
% x  - inputs
% m  - mean predictions
% s2 - prediction errors
% xt - optional: training inputs
% yt - optional: training outputs

f = [m + 2*sqrt(s2); flipdim(m - 2 * sqrt(s2), 1)]; 

fill([x; flipdim(x, 1)], f, [7 7 7] / 8)
hold on; 
plot(x, m); 

if nargin == 5
  plot(xt, yt, '+')
end
