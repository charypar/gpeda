function [m s2] = modelPredictGPS(M, z)
% MODELPREDICTGPS Returns predicted values of GP for data z
%
% [m s2] = MODELPREDICTGPS(M, z)
% Makes predictions for input matrix z of size n by D using model M (obtained with modelInit and modelTrain)
%
% Returns mean and std. deviation for each predicted output
%
% See also
% MODELINIT, MODELINITGPS, MODELTRAIN, MODELTRAINGPS, MODELPREDICT

[m s2] = gpPosteriorMeanVar(M.m, z);
% gpPosteriorMeanVar gives negative s2 :(
s2 = max(s2, zeros(size(s2)));
