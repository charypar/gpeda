function pop = sampleMCPOI(M, lb, ub, n, opts);
% Monte-Carlo sampler based on Probability of improvement
dif = ub - lb;

pop = zeros(n, M.dim);

for i = 1:n 
  while 1
    s = lb + rand(1, M.dim) .* dif;
    p = modelGetPOI(M, s, opts.target);

    if rand < p
      break;
    end
  end
  pop(i, :) = s;
end




