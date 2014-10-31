function [s tolXDistRatio maxLogPdf] = sampleSlice(M, dim, nsamples, attempt, spar)
% Slice sampler -- very testing version!
% historic output: neval (not anymore)

if (~isfield(spar, 'minTolX'))
  spar.minTolX = 0.002; % the minimum distance in X's to any point 
                        % in the dataset, lower produces numerical
                        % instability (not posit. definite covariance
                        % matrices in the GP model)
end

bestX = attempt.bests.x(end,:);
currBestY = attempt.bests.yms2(end,1);
currWorstY = min(attempt.dataset.y);
tolXDistRatio = 0;

thresholds = [0 0.001 0.01 0.3];
% % FORMER THRESHOLDS:
% thresholds = [0 0.001 1.0];
% thresholds = [0 0.001 0.30 1.0 3.0];
% thresholds = flipdim(thresholds, 2);

% TODO: evaluate, that this is right, not stupid as it was!!! (27 Oct 2014)
targets = currBestY + thresholds .* (currWorstY - currBestY);
%
% % THIS IS STUPID!!!
% targets = currBestY * (1 - thresholds .* (currWorstY - currBestY));

% check if covariance matrix is positive definite
lx = size(attempt.dataset.x,1);
spd = isCovarianceSPD(M, attempt.dataset.x);
if (spd < lx)
  exception = MException('sampleGibbs:CovarianceMatrixNotSPD', ...
              ['The matrix is not positive definite: p (from LL decomp) = ' num2str(lx - spd)]);
  tolXDistRatio = 1;
  throw(exception);
end

errCode = -1; i = 1;
s = [];
nTolXErrors = 0;
neval = 0;
while (errCode ~= 0 && i <= length(thresholds))
  % seems that only function proportional to PDF is sufficient
  logdensity = @(xSpace) log(modelGetPOI(M, xSpace, targets(i)));

  % start at the current best point -- there sould be at least some PoI > 0
  startX = bestX;
  [s_, neval_, errCode, nTolXErrors_, maxLogPdf] = myslicesample(startX, nsamples, 'logpdf', logdensity, 'burnin', 100, 'thin', 10, 'width', 1*ones(1,dim), 'dataset', attempt.dataset.x, 'minTolX', 0.002, 'model', M);
  neval = neval + neval_;

  if (size(s_,1) > size(s,1))
    s = s_;
    nTolXErrors = nTolXErrors_;
  end
  if (maxLogPdf < log(10e-10))
    % maximum sampled logpdf is tooo looow :(
    errCode = 3;
  end

  switch (errCode)
  case 1
    disp(['sampleSlice(): There is no probability of improvement with threshold ' num2str(thresholds(i))]);
  case 2
    disp(['sampleSlice(): Could not sample enough individuals far enough between each other with threshold ' num2str(thresholds(i))]);
  case 3
    disp(['sampleSlice(): The maximal logpdf is low: min(logpdf) = ' num2str(maxLogPdf)]);
  end
  i = i + 1;
end

if (nTolXErrors > 0)
  disp(['sampleSlice(): Note: sampling in narrow region: nTolXErrors == ' num2str(nTolXErrors)]);
  tolXDistRatio = nTolXErrors/nsamples;
else
  tolXDistRatio = 0;
end

