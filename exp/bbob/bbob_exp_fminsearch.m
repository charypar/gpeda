% runs an entire experiment for benchmarking MY_OPTIMIZER
% on the noise-free testbed. fgeneric.m and benchmarks.m
% must be in the path of Matlab/Octave
% CAPITALIZATION indicates code adaptations to be made

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
%  EXPERIMENT GLOBAL SETTINGS
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

addpath('../vendor/bbob');  % should point to fgeneric.m etc.
datapath = 'output/exp_fminsearch';  % different folder for each experiment
  pathstr = fileparts(mfilename('fullpath'));
  datapath = [pathstr filesep datapath];
% opt.inputFormat = 'row';

opt.algName = 'GPEDA v 0.1';
opt.comments = 'GPEDA, Gaussian-Processes EDA, first experiment at all';

maxfunevals = '10 * dim'; % 10*dim is a short test-experiment taking a few minutes 
                          % INCREMENT maxfunevals successively to larger value(s)
minfunevals = 'dim + 2';  % PUT MINIMAL SENSIBLE NUMBER OF EVALUATIONS for a restart
maxrestarts = 1e4;        % SET to zero for an entirely deterministic algorithm

dimensions  = [2 3 5];    % which dimensions to optimize, subset of [2 3 5 10 20 40];

functions   = [1 2 3];    % function ID's to optimize
% functions   = benchmarks('FunctionIndices');

opt_function = @opt_fminsearch; % function being optimized -- BBOB wrap-around with header
                                % xbest = function( fun, dim, ftarget, maxfunevals )

% configuration done run the common experiment loop
run('bbob_exp_common');

