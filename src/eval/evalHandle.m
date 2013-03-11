function y = evalHandle(x, m, s2, params)
% Simple direct function evaluation
% x  - input point
% m  - model prediction
% s2 - model error estimate

y = feval(params.handle, x);
