function [m s2] = modelPredict(M, z)
% Makes predictions for input matrix z of size n by D using model M (obtained with modelInit and modelTrain)
%
% Returns mean and std. deviation for each predicted output

[m s2] = gp(M.hyp, M.inffunc, M.meanfunc, M.covfunc, M.likfunc, ...
            M.dataset.x, M.dataset.y, z);

