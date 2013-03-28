function [s tolXDistRatio] = sampleSlice(M, dim, nsamples, attempt, spar)
% Slice sampler -- very testing version!

startX = 2 * rand(1,dim) - 1;

currBestY = attempt.bests.yms2(end,1);
currWorstY = min(attempt.dataset.y);
tolXDistRatio = 0;

thresholds = [0 0.001 0.30 1.0 3.0];
thresholds = flipdim(thresholds, 2);
targets = currBestY * (1 - thresholds .* (currWorstY - currBestY));

i = 1;
while (i <= length(thresholds))
  density = @(xSpace) modelGetPOI(M, xSpace, targets(i));

  s = slicesample(startX, nsamples, 'pdf', density, 'burnin', 100, 'thin', 10);
  i = i + 1;
end
