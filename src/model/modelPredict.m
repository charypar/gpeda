function [m s2] = modelPredict(M, z)
% Makes predictions for input matrix z of size n by D using model M (obtained with modelInit and modelTrain)
%
% Returns mean and std. deviation for each predicted output

%{
  % GP Lawrence version
  [m s2] = gpPosteriorMeanVar(M.m, z);
  % gpPosteriorMeanVar gives negative s2 :(
  s2 = max(s2, zeros(size(s2)));
%}

[m s2] = gp(M.hyp, M.inffunc, M.meanfunc, M.covfunc, M.likfunc, M.dataset.x, M.dataset.y, z);
