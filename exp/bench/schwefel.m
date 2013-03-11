function z = schwefel(x)
n = size(x, 2);

s = sum(-x .* sin(sqrt(abs(x))), 2);

z = 418.9829*n + s;