function y = evalHandle(x, m, s2, opts)
% Simple direct function evaluation
% x  - input matrix (n by dim)
% m  - model prediction vector (length dim) - empty for initial evaluation in DoE
% s2 - model error estimate vector (length dim) - empty for initial evaluatio in DoE
% opts - options struct, most importantly the handle
%        handle - function handle taking one arugment - input matrix x - returning an output vector y

y = feval(opts.handle, x);
