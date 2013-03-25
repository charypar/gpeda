clear all; close all; clc;

[x y] = testGP(30, 0.1);

% Train a model on the samples and make predictions

M = modelInit(1); % the default
M = modelTrain(M, x, y);

z = linspace(-5, 5, 101)';
[m s2] = modelPredict(M, z);

poi = modelGetPOI(M, z, -1.3);

plotErr1(z, m, s2, x, y);
title('Prediction with learned hyperparameters (and correct process structure)');

hold on;
plot(z, poi, 'g-');
plot([-5 5], [0 0], 'k-');
plot([-5 5], [-1.3 -1.3], 'k--');
