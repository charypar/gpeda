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

modelTrainNErrors = 0;
% model.hyp = minimize(model.hyp, @gp, -100, model.inffunc, model.meanfunc, model.covfunc, model.likfunc, x, y);
model.hyp = minimize(model.hyp, @gp, -100, @infExactCountErrors, model.meanfunc, model.covfunc, model.likfunc, x, y);
% FIXME: holds for infExact() only -- do not be sticked to infExact!!!

nErrors = modelTrainNErrors;
Mout = model;

function [post nlZ dnlZ] = infExactCountErrors(hyp, mean, cov, lik, x, y)
  try
    [post nlZ dnlZ] = infExact(hyp, mean, cov, lik, x, y);
  catch err
    modelTrainNErrors = modelTrainNErrors + 1;
    throw(err);
  end
end

end
