function [yopt evals] = runStat(y_evals)

c = 1;
y_evals = [NaN 1; y_evals];
curr_min = Inf;

evals = 1:500;
for i = 1:500
  while (size(y_evals,1) > c  &&  y_evals(c+1,2) == i)
    c = c + 1;
    curr_min = min(curr_min, y_evals(c,1));
  end
  yopt(i,:) = curr_min;
end
