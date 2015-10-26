% Startup script to set paths right so the package works

disp(['Starting GPEDA, setting path...']);

% add src directories
addpath('src');
addpath(['src' filesep 'eval']);
addpath(['src' filesep 'doe']);
addpath(['src' filesep 'sample']);
addpath(['src' filesep 'stop']);
addpath(['src' filesep 'model']);
addpath(['src' filesep 'util']);

% add exp directories
addpath('exp');
addpath(genpath('exp'));

% setup the GPML package
run(['src' filesep 'vendor' filesep 'gpml-matlab-v3.2' filesep 'startup']);
