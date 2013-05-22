function [pop fval exflag] = findModelMinimum(model, thisAttempt, dim)
  gp_predict = @(x_gp) modelPredict(model, x_gp);
  % % this is GADS Toolbox, which we dont have license for :(
  %{
  got_opts = optimset('Algorithm', 'interior-point');
  problem = createOptimProblem('fmincon', 'objective',...
    gp_predict,'x0',run.attempts{att}.bests.x(end,:),'lb',-1,'ub',1,'options',got_opts);
  gs = GlobalSearch;
  [minimum,fval] = run(gs, problem);
  %}

  % this is Matlab core fminsearch() implementation
  fminoptions = optimset('MaxFunEvals', min(1e8*dim), ...
    'MaxIter', 1000*dim, ...
    'Tolfun', 1e-10, ...
    'TolX', 1e-10, ...
    'Display', 'off');
  [pop fval exflag output] = fminsearch(gp_predict, thisAttempt.bests.x(end,:), fminoptions);
  disp(['  fminsearch(): ' num2str(output.funcCount) ' evaluations.']);
end

