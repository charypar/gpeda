function [s tolXDistRatio] = sampleGibbs(M, dim, nsamples, attempt, spar)
% Gibbs MCMC sampler based on Probability of improvement
%
% M             GP model
% lb, ub        bounds within it should be sampled
% nsamples      the number of samples to be drawn
% spar.target   target value for computing probability of improvement

startX = attempt.bests.x(end,:);
currBestY = attempt.bests.yms2(end,1);
currWorstY = min(attempt.dataset.y);

thresholds = [0 0.0001 0.001 (0.01 * (1:13)) 0.15 0.20 0.25 ...
  0.30 0.40 0.50 0.75 1.0 1.5 2.0 3.0];
thresholds = flipdim(thresholds, 2);
targets = currBestY * (1 - thresholds .* (currWorstY - currBestY));

errCode = -1; i = 1;
while (errCode ~= 0 && i <= length(thresholds))
  density = @(xSpace) modelGetPOI(M, xSpace, targets(i));

  % DEBUG
  % debugGridSize = 201;
  % [xyColumn xm ym] = grid2d(lb, ub, debugGridSize);
  % poi = density(xyColumn);
  % % f = figure();
  % s1 = subplot(2,2,[1 3]);
  % [~, sf] = contour(xm, ym, reshape(poi, debugGridSize, debugGridSize));
  % colorbar();
  % s2(1) = subplot(2,2,2);
  % s2(2) = subplot(2,2,4);
  % debugArgs = {};
  % /DEBUG

  [s, errCode] = gibbsSampler(density, dim, nsamples, startX); % , debugArgs);
  if (errCode)
    disp(['sampleGibbs(): There is no probability of improvement with threshold ' num2str(thresholds(i))]);
  end
  i = i + 1;
end

if (errCode)
  error('sampleGibbs(): There is no probability of improvement. Giving up.');
end

tolXDistRatio = 1;

function [s, errCode] = gibbsSampler(density, dim, nsamples, startX, debugArgs)
% Gibbs MCMC sampler itself
%
% M             GP model
% lb, ub        bounds within it should be sampled
% nsamples      the number of samples to be drawn
% spar.target   target value for computing probability of improvement

% Parameters
thin = dim * 20;         % the number of discarted samples between actual draws
gridSize = 400;         % the number of samples of POI from which the 
                        % marginal's inverse CDF is estimated
nSamplePOITries = 5;    % how many times the POI is sampled, each time
                        % with double dense grid (the *gridSize*
                        % is doubled each try)
minSampledPoints = 8;   % the minimum number of points to get
                        % good-shaped probability
sampleDistanceTol = 0.002;
difx = 2;

% Prior Values -- generate all the variables from Normal distribution
% centered along current best point
x = startX .* (difx/8 .* randn(1,dim));

%Allocate Space to Save Gibbs Sampling Draws
s = zeros(nsamples,dim);
errCode = 0;
highestPOI = -Inf;
highestPOIX = zeros(1,dim);

% Run the Gibbs Sampler...
% ... for the specified number of draws
% - leave one sample for the biggest PoI found by this run
for i = 1:(nsamples - 1)
  for j = 1:thin
    % take the variables in random order
    for k = 1:dim % randperm(dim)
      % Estimate inverse CDF of the chosen marginal
      % at (x_1,...,x_(k-1), X, x_(k+1),...,x_(dim))
      
      % sample the probability of improvement (POI)
      % if less than *minSampledPoints* with non zero probability 
      % is returned, give it *nSamplePOITries* tries doubling the number 
      % of sampled points each time
      nPoints = 0; tryNo = 1; sampleSize = gridSize;
      while ((nPoints < minSampledPoints) && (tryNo <= nSamplePOITries))
        xGrid = linspace(-1, 1, sampleSize)';
        xSpace = repmat(x,length(xGrid),1);
        xSpace(:,k) = xGrid;
        poi_density = density(xSpace);
        empIntegral = sum(poi_density);
        
        % save maximal POI found so far
        [maxPOI, mpi] = max(poi_density);
        if (maxPOI > highestPOI)
          highestPOI = maxPOI; highestPOIX = xSpace(mpi,:);
        end

        nonzeroProb = (poi_density./empIntegral > eps);
        nPoints = sum(nonzeroProb);
        sampleSize = 2 * sampleSize;
        tryNo = tryNo + 1;
      end

      xGrid = xGrid(nonzeroProb,:);
      poi_density = poi_density(nonzeroProb);
      
      if (nPoints == 0)
        % warning('sampleGibbs(): There is no probability of improvement. Giving up.');
        errCode = 1;
        return
      end
      if (nPoints == 1)
        warning('sampleGibbs(): There is practically zero probability of improvement. Numerical instability possible.');
        F = [0; 0.5; 1];
        kernel_width = 0.005 * difx;
        xGrid = xGrid + kernel_width * [-1 0 1];
      else
        if (nPoints < minSampledPoints)
          % warning('sampleGibbs(): The probability of improvement is very local. Numerical instability possible.')
        end
        F_step = cumsum(poi_density);             % empirical step-like cumsum; last item = integral
        F_step = F_step ./ F_step(end);           % calculate empirical CDF by dividing by the integral
        F = ([0; F_step(1:end-1)] + F_step)/2;    % midpoints CDF
        % augment the midpoints CDF on bounds to start at 0 and end at 1
        %   copy slope of this parts from the first/last part of the midpoint CDF
        optOut = (F < sqrt(eps)) | (F > (1 - sqrt(eps)));
        F(optOut) = [];
        xGrid(optOut) = [];
        xGrid = [xGrid(1) - F(1)*(xGrid(2)-xGrid(1))/(F(2)-F(1)); ...
          xGrid; ...
          xGrid(end) + (1-F(end))*(xGrid(end)-xGrid(end-1))/(F(end)-F(end-1))];
        F = [0; F; 1];
      end
      
      % draw a sample from the estimated marginal 1D distribution
      % - sample the uniform U[0,1] and put this value into the inverse CDF
      % - inverse CDF is taken as linear interpolation of inverted 
      %   empirical CDF
      new_x = interp1(F, xGrid, rand(), 'linear', 'extrap');
      % replace the current covariate by this sampled value
      x(k) = new_x;

      % DEBUG
      % plot(debugArgs{2}(k), xSpace(nonzeroProb,k), poi_density, 'g-');
      % margins = [x' x'];
      % margins(k,:) = [lb(k) ub(k)];
      % hold(debugArgs{1},'on');
      % plot(debugArgs{1}, margins(1,:), margins(2,:), 'g-');
      % hold(debugArgs{1},'off');
      % /DEBUG
    end
    % DEBUG
    % hold(debugArgs{1},'on');
    % plot(debugArgs{1}, x(1), x(2), 'r+');
    % hold(debugArgs{1},'off');
    % /DEBUG
  end
  s(i,:) = x;
  % DEBUG
  % hold(debugArgs{1},'on');
  % plot(debugArgs{1}, x(1), x(2), 'b*');
  % hold(debugArgs{1},'off');
  % /DEBUG
end

% save the best POI found
s(nsamples,:) = highestPOIX;

