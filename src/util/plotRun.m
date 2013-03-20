function plotRun(run)
% Plots the optimization course

bestys = cellReduce(cellMap(run.attempts, @(attempt)( attempt.bests.yms2(:, 1) )), @(all, run)([all; run]), []);
attlengths = cell2mat(cellMap(run.attempts, @(att)( att.iterations )));
resets = cumsum(attlengths);

plot(1:length(bestys), bestys);
xlim([1 length(bestys)]);
hold on;
for(i = 1:length(resets)-1)
  line([resets(i) resets(i)], ylim, 'Color', 'r');
end

