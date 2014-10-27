function [M medians evals] = completeRunStat(y_evals, varargin)
  if (nargin > 1)
    N = varargin{1};
  else
    N = 500;
  end

  evals = 1:N;

  M = zeros(N,length(y_evals));
  for i = 1:length(y_evals)
    M(:,i) = runStat(y_evals{i}, N) + 1e-8;
  end
  medians = median(M, 2);
end
