function [yopt evals] = runStat(y_evals, varargin)

c = 1;
y_evals = [NaN 1; y_evals];
curr_min = Inf;

if (nargin > 1)
  N = varargin{1};
else
  N = 500;
end

evals = 1:N;
for i = 1:N
  while (size(y_evals,1) > c  &&  y_evals(c+1,2) == i)
    c = c + 1;
    curr_min = min(curr_min, y_evals(c,1));
  end
  yopt(i,:) = curr_min;
end
