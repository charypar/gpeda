function s = sampleGibbs(M, lb, ub, spar);
% Gibbs MCMC sampler based on Probability of improvement
%
% spar.nsamples - the number of draws to be returned

% Parameters
thin = M.dim * 5;     % the number of discarted samples between draws
margin_discr = 50       % the number of sampels the marginal's inverse
                        % CDF is estimated from


% Prior Values -- generate all the variables from Normal distribution
x = randn(1,M.dim);

%Allocate Space to Save Gibbs Sampling Draws
s = zeros(spar.nsamples,M.dim);

% Run the Gibbs Sampler...
% ... for the specified number of draws
for i = 1:spar.nsamples
  for j = 1:thin
    % take the variables in random order
    for k = randperm(M.dim)
      % Estimate inverse CDF of the chosen marginal
      % at (x_1,...,x_(k-1), X, x_(k+1),...,x_(M.dim))
      x_grid = linspace(lb(k),ub(k),margin_discr);
      poi_grid = modelGetPOI(M, xgrid, spar.target);
      F2 = cumsum(poi_grid);
      F2 = F2 ./ F2(end);               % calculate PDF by dividing by the integral
      F = (F2(1:end-1)+F2(2:end))/2;    % midpoints CDF (length(F2) - 1)
      % augment x_grid for being able to have boundary values 0.0 and 1.0
      n = length(F);
      x_2end = x_grid(2:end);           % x_values for midpoints CDF
      % add lowest linear approximation at 0
      xCDFRange = [x_2end(1) - F(1)*(x_2end(2)-x_2end(1))/(F(2)-F(1)) ...
        x_2end];
        % % OMITTED: highest linear approximation for 1
        % x_2end(n) - (1-F(n))*(x_2end(n)-x_2end(n-1))/(F(n)-F(n-1))];
      % expand the CDF at 0 too
      F = [0 F];
      % draw a sample from the final distribution
      % - inverse CDF is taken as linear interpolation of inverse CDF
      % - this iCDF simply converse sample from uniform distribution
      new_x = interp1(F, xCDFRange, rand(), 'linear', 'extrap');
      % replace the current covariate by this sampled value
      x(k) = new_x;
    end
  end
  s(i,:) = x;
end
