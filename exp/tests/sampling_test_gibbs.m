clear all; close all; clc;

[x y] = testGP(30, 0.1);

% Train a model on the samples and make predictions

M = modelInit(1); % the default
M = modelTrain(M, x, y);

z = linspace(-5, 5, 101)';
[m s2] = modelPredict(M, z);

spar.target = -1.0;
poi = modelGetPOI(M, z, spar.target);

plotErr1(z, m, s2, x, y);
title('Prediction with learned hyperparameters (and correct process structure)');

hold on;
plot(z, poi, 'g-');
plot([-5 5], [0 0], 'k-');
plot([-5 5], [spar.target spar.target], 'k--');

% Now sample a population of 50 individuals accoriding to PoI
nsamp = 20;
population = sampleGibbs(M, -5, 5, nsamp, spar);

plot(population, zeros(1, nsamp), 'rx');
