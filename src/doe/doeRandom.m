function x = doeRandom(D, options)
% Random design of experiment. Selects n random points uniformly distributed between lower
% bound lb and upper bound ub. Options are unused.

generate = @(n) 2 * rand(n, D) - 1;

x = generate(options.n);

nWrong = 1;

if (~isfield(options, 'maxSampleTries'))
  options.maxSampleTries = 10;
end

i = 0;
while (nWrong > 0 && i < options.maxSampleTries)
  dists = sqrt(sq_dist(x') + eye(length(x)));

  whereTolXErrorMatrix = triu(dists < options.minTolX, 1);
  whereTolXErrorBool = sum(whereTolXErrorMatrix,1) > 0;
  nWrong = sum(whereTolXErrorBool);

  xNew = generate(nWrong);
  x(whereTolXErrorBool,:) = xNew;
  
  i = i + 1;
end

if (i >= options.maxSampleTries)
  error('doeRandom:SampleTriesRanOut', ...
    ['Maximal number of tries to sample data was not enough for data '...
     'to be spread for at least options.minTolX = ' num2str(options.minTolX)]);
end
        
