function [Mout nErrors] = modelTrain(M, x, y, varargin)
% Trains model M initialized with modelInit on data x, y
% 
% M - model structure
% x - input matrix of size n x D where D is the model dimension
% y - ouput column vector of length n
%
% Returns a new model Mout fitted to the data

global modelTrainNErrors;
% FIXME: rewrite without global variable!

model = struct(M); % copy the original model
model.dataset.x = x; model.dataset.y = y; % store dataset

hyp = model.hyp;

alg = 'minimize';
if (nargin > 3 && isstruct(varargin{1}))
  opts = varargin{1};
  if (isfield(opts, 'trainAlgorithm') && strcmpi(opts.trainAlgorithm, 'fmincon'))
    alg = 'fmincon';
  elseif (isfield(opts, 'trainAlgorithm') && strcmpi(opts.trainAlgorithm, 'cmaes'))
    alg = 'cmaes';
  end
end

if (strcmp(alg, 'fmincon') || strcmp(alg, 'cmaes'))
  % fmincon() from Optimization toolbox
  % f = @(par) linear_gp([par(1:2) log(par(3:4) par(5)], hyp, @infExactCountErrors, model.meanfunc, model.covfunc, model.likfunc, x, y);
  f = @(par) linear_gp(par, hyp, @infExactCountErrors, model.meanfunc, model.covfunc, model.likfunc, x, y);
  
  linear_hyp = unwrap(hyp)';
  l_cov = length(hyp.cov);
  
  % lower and upper bounds
  lb_hyp.cov = -2 * ones(size(hyp.cov));
  lb_hyp.inf = log(1e-7);
  lb_hyp.lik = log(1e-7);
  lb_hyp.mean = -Inf;
  lb = unwrap(lb_hyp)';
  ub_hyp.cov = 25 * ones(size(hyp.cov));
  ub_hyp.inf = log(7);
  ub_hyp.lik = log(7);
  ub_hyp.mean = Inf;
  ub = unwrap(ub_hyp)';
  
  % lb = [-10 -10 log(1e-7) log(1e-7) -Inf];
  % ub = [ 25  25 log(7) log(7) Inf];
  if (strcmp(alg, 'fmincon'))
    options = optimset('GradObj', 'on', ...
            'TolFun', 1e-8, ...
            'TolX', 1e-8, ...
            'MaxIter', 1000, ...
            'MaxFunEvals', 1000, ...
            'Display', 'final');
    if (length(hyp.cov) > 2)
      % ARD
      options = optimset(options, 'Algorithm','interior-point');
      nonlnc = @nonlincons;
    else
      % ISOtropic
      options = optimset(options, 'Algorithm','trust-region-reflective');
      nonlnc = [];
    end
    initial = f(linear_hyp');
    % DEBUG OUTPUT:
    disp(['Model training, init fval = ' num2str(initial)]);
    if isnan(initial)
      alg = 'cmaes';
    else
      % training itself
      [opt1, fval1] = fmincon(f, linear_hyp', [], [], [], [], lb, ub, nonlnc, options);
      if (isnan(fval1))
        alg = 'cmaes';
      end
      fval = fval1;
      opt = opt1;
      %{
      % try CMA-ES if performes better
      cmaesopt.MaxFunEvals = 2000;
      cmaesopt.LBounds = lb';
      cmaesopt.UBounds = ub';
      status = warning('off');
      [opt2, fval2] = cmaes(f, linear_hyp', [0.3*(ub(1:(end-1)) - lb(1:(end-1))) 100]', cmaesopt);
      warning(status);
      % % try Rasmussen's minimize() as well
      % [opt_, fval3] = minimize(model.hyp, @gp, -100, @infExactCountErrors, model.meanfunc, model.covfunc, model.likfunc, x, y);
      % opt3 = unwrap(opt_);
      
      disp(['fmincon:  ' num2str(fval1)]);
      disp(['cmaes:    ' num2str(fval2)]);
      % disp(['minimize: ' num2str(fval3)]);
      [fm, fi] = min([fval1 fval2]); % fval2]);
      fval = fm;
      opts = [opt1 opt2]; % opt3];
      opt = opts(:, fi);
      %}
    end
  end
  if (strcmp(alg, 'cmaes'))
    cmaesopt.LBounds = lb';
    cmaesopt.UBounds = ub';
    if (length(hyp.cov) > 2)
      % there is ARD covariance
      % try run cmaes for 500 funevals to get bounds for covariances
      cmaesopt.MaxFunEvals = 500;
      [opt, fval] = cmaes(f, linear_hyp', [0.3*(ub(1:(end-1)) - lb(1:(end-1))) 100]', cmaesopt);
      cov_median = median(opt(1:(end-4)));
      ub(1:(end-4)) = cov_median + 2.5;
      lb(1:(end-4)) = cov_median - 2.5;
      cmaesopt.LBounds = lb';
      cmaesopt.UBounds = ub';
    end
    cmaesopt.MaxFunEvals = 2000;
    [opt, fval] = cmaes(f, linear_hyp', [0.3*(ub(1:(end-1)) - lb(1:(end-1))) 100]', cmaesopt);
  end

  model.hyp = rewrap(hyp, opt);
  modelTrainNErrors = 0;
  nErrors = modelTrainNErrors;
  Mout = model;

  % DEBUG OUTPUT:
  fprintf('Final fval = %f, hyperparameters: ', fval);
  disp(model.hyp);

else

  modelTrainNErrors = 0;
  % model.hyp = minimize(model.hyp, @gp, -100, model.inffunc, model.meanfunc, model.covfunc, model.likfunc, x, y);
  model.hyp = minimize(model.hyp, @gp, -100, @infExactCountErrors, model.meanfunc, model.covfunc, model.likfunc, x, y);
  % FIXME: holds for infExact() only -- do not be sticked to infExact!!!

  nErrors = modelTrainNErrors;
  Mout = model;
end

end

function [post nlZ dnlZ] = infExactCountErrors(hyp, mean, cov, lik, x, y)
  try
    [post nlZ dnlZ] = infExact(hyp, mean, cov, lik, x, y);
  catch err
    modelTrainNErrors = modelTrainNErrors + 1;
    throw(err);
  end
end

function [nlZ dnlZ] = linear_gp(linear_hyp, s_hyp, inf, mean, cov, lik, x, y)
  hyp = rewrap(s_hyp, linear_hyp');
  [nlZ s_dnlZ] = gp(hyp, inf, mean, cov, lik, x, y);
  dnlZ = unwrap(s_dnlZ)';
end

function [c ceq] = nonlincons(x)
  % checks if the values x(1:(end-4)) are within 2.5 off median
  MAX_DIFF = 2.5;
  ceq = [];
  assert(size(x,2) == 1, 'Argument for nonlincons is not a vector');
  c = zeros(size(x));
  % test only for covariance parameters
  % TODO: are there always 4 more parameters?!
  c = abs(x(1:end-4) - median(x(1:end-4))) - MAX_DIFF;
end
