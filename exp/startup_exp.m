% Startup script to set paths to GPEDA experiments

disp(['setting paths to exp/...']);

% path-part of the current filename
pathstr = fileparts(mfilename('fullpath'));

addpath(pathstr);

% get all the subdirectories of this path
p = genpath(pathstr);

addpath(p);

% pathsToAdd = {'bbob' 'bbob' 'bench' 'tests' 'util' 'vendor ' 'vendor/bbob' 'vendor/cmaes'};
% for i = 1:length(pathsToAdd)
%   disp([pathstr filesep pathsToAdd{i}]);
%   addpath([pathstr filesep pathsToAdd{i}]);
% end
