% Startup script to set paths right so the package works

disp(['Starting GPEDA, setting path...']);

fname = mfilename;

dirname = which(fname); 
dirname = dirname(1:end - 2 - numel(fname));

addpath(dirname(1:end - 1))

addpath([dirname, 'eval'])
addpath([dirname, 'model'])
addpath([dirname, 'sampler'])

% setup the GPML package
run([dirname, 'vendor/', 'gpml-matlab-v3.2/', 'startup'])

