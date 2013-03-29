function [M medians evals] = completeRunStat(y_evals)
  evals = 1:500;

  M = zeros(500,length(y_evals));
  for i = 1:length(y_evals)
    M(:,i) = runStat(y_evals{i});
  end
  medians = median(M, 2);
end
