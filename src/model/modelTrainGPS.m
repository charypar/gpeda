function [model nErrors] = modelTrainGPS(M, x, y)
% MODELTRAINGPS Trains a GP model, based on ''netlab'' package
%
% [model, nErrors] = MODELTRAINGPS(M, x, y) 
% Trains model M initialized with modelInit on data x, y
% 
% M - model structure
% x - input matrix of size n x D where D is the model dimension
% y - ouput column vector of length n
%
% Returns a new model fitted to the data
%
% See also
% MODELTRAIN

assert(isfield(M, 'options'), 'Assertion failed: options not exist in M');
assert(size(x,1) > 0 && (size(x,1) == size(y,1)), 'Assertion failed: Input data dimensions does not match.');

model = struct(M); % copy the original model
model.dataset.x = x; model.dataset.y = y; % store dataset

xDim = size(x, 2);
yDim = size(y, 2);
model.m = gpCreate(xDim, yDim, x, y, M.options);

% Train the model
display = 1;
iters = 1000;
model.m = gpOptimise(model.m, display, iters);

if (nargout > 1)
  nErrors = 0;
end
