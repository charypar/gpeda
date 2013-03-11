function s = samplerMCPOI(M, lb, ub, target);
% Monte-Carlo sampler based on Probability of improvement
dif = ub - lb;

while 1
  s = lb + rand(1, M.dim) .* dif;
  p = modelGetPOI(M, s, target);

  if rand < p
    return;
  end
end
