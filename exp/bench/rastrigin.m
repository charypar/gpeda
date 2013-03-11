function y = rastrigin(x)
y = 10*size(x, 2) + sum(x.^2 - 10*cos(2*pi*x), 2);