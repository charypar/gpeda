function [Mout nErrors] = modelTrain(M, x, y)
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
f = @(par) linear_gp(par, hyp, @infExactCountErrors, model.meanfunc, model.covfunc, model.likfunc, x, y);

linear_hyp = unwrap(hyp)';
l_cov = length(hyp.cov);
lb = [zeros(1,l_cov) -Inf * ones(1,length(linear_hyp)-l_cov)];
ub = [20 * ones(1,l_cov) Inf * ones(1,length(linear_hyp)-l_cov)];
options = optimset('GradObj', 'on', ...
        'TolFun', 1e-8, ...
        'TolX', 1e-8, ...
        'MaxIter', 1000, ...
        'MaxFunEvals', 1000, ...
        'Display', 'final');
disp('Model training...');
opt = fmincon(f, linear_hyp', [], [], [], [], lb, ub, [], options);

model.hyp = rewrap(hyp, opt);
modelTrainNErrors = 0;
nErrors = modelTrainNErrors;
Mout = model;

% DEBUG OUTPUT:
fprintf('Final hyperparameters: ');
disp(model.hyp);

%{
modelTrainNErrors = 0;
% model.hyp = minimize(model.hyp, @gp, -100, model.inffunc, model.meanfunc, model.covfunc, model.likfunc, x, y);
model.hyp = minimize(model.hyp, @gp, -100, @infExactCountErrors, model.meanfunc, model.covfunc, model.likfunc, x, y);
% FIXME: holds for infExact() only -- do not be sticked to infExact!!!

nErrors = modelTrainNErrors;
Mout = model;
%}

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
