function Mout = modelTrain(M, x, y)
% Trains model M initialized with modelInit on data x, y
% 
% M - model structure
% x - input matrix of size n x D where D is the model dimension
% y - ouput column vector of length n
%
% Returns a new model Mout fitted to the data

model = struct(M); % copy the original model
model.dataset.x = x; model.dataset.y = y; % store dataset

model.hyp = minimize(model.hyp, @gp, -100, model.inffunc, model.meanfunc, model.covfunc, model.likfunc, x, y);

Mout = model;
