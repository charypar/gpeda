clear; close all; clc;

M = modelInit(1);
x = doeRandom(-5, 5, struct('n', 20));
y = x.^2;

plot(x, y, 'o');

M = modelTrain(M, x, y);

z = linspace(-5, 5, 101)';
[m s2] = modelPredict(M, z);

plotErr1(z, m, s2, x, y);
title('Prediction with learned hyperparameters (and correct process structure)');

hold on;
plot([-5 5], [0 0], 'k-');
plot([-5 5], [-1.3 -1.3], 'k--');
