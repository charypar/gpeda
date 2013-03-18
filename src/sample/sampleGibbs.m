function s = sampleGibbs(M, lb, ub, nsamples, spar)
% Gibbs MCMC sampler based on Probability of improvement
%
% M             GP model
% lb, ub        bounds within it should be sampled
% nsamples      the number of samples to be drawn
% spar.target   target value for computing probability of improvement

% Parameters
thin = M.dim * 5;       % the number of discarted samples between actual draws
gridSize = 200;         % the number of samples of POI from which the 
                        % marginal's inverse CDF is estimated
nSamplePOITries = 5;    % how many times the POI is sampled, each time
                        % with double dense grid (the *gridSize*
                        % is doubled each try)
minSampledPoints = 8;   % the minimum number of points to get
                        % good-shaped probability

% Prior Values -- generate all the variables from Normal distribution
x = randn(1,M.dim);

%Allocate Space to Save Gibbs Sampling Draws
s = zeros(nsamples,M.dim);

% Run the Gibbs Sampler...
% ... for the specified number of draws
for i = 1:nsamples
  for j = 1:thin
    % take the variables in random order
    for k = randperm(M.dim)
      % Estimate inverse CDF of the chosen marginal
      % at (x_1,...,x_(k-1), X, x_(k+1),...,x_(M.dim))
      
      % sample the probability of improvement (POI)
      % if less than *minSampledPoints* with non zero probability 
      % is returned, give it *nSamplePOITries* tries doubling the number 
      % of sampled points each time
      nPoints = 0; tryNo = 1; sampleSize = gridSize;
      while ((nPoints < minSampledPoints) && (tryNo <= nSamplePOITries))
        xGrid = linspace(lb(k), ub(k), sampleSize)';
        xSpace = repmat(x,length(xGrid),1);
        xSpace(:,k) = xGrid;
        poi_density = modelGetPOI(M, xSpace, spar.target);
        empIntegral = sum(poi_density);

        nonzeroProb = (poi_density./empIntegral > eps);
        nPoints = sum(nonzeroProb);
        sampleSize = 2 * sampleSize;
        tryNo = tryNo + 1;
      end

      xGrid = xGrid(nonzeroProb,:);
      poi_density = poi_density(nonzeroProb);
      
      if (nPoints == 0)
        error('sampleGibbs(): There is no probability of improvement. Giving up.');
        return
      end
      if (nPoints == 1)
        warning('sampleGibbs(): There is practically zero probability of improvement. Numerical instability possible.');
        F = [0; 0.5; 1];
        kernel_width = 0.005 * (ub(k) - lb(k));
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
    end
  end
  s(i,:) = x;
end