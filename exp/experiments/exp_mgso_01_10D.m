exp_id = 'exp_mgso_01_10D';
exp_description = 'MGSO with a guessed settings, 24 functions, 15 instances -- the first try';

login = 'bajel3am';
if (strfind(mfilename('fullpath'), 'afs'))
  matlabcommand = '/afs/ms/@sys/bin/matlab';
else
  matlabcommand = 'matlab_mff_2014b';
end
logMatlabOutput = true;
logDir = '/storage/plzen1/home/bajeluk/public';

% BBOB parameters
bbParamDef(1).name   = 'dimensions';
bbParamDef(1).values = { 10 };             % {2, 3, 5, 10, 20};
bbParamDef(2).name   = 'functions';
bbParamDef(2).values = num2cell(1:24);  % {1, 2, 3, 5, 6, 8, 10, 11, 12, 13, 14, 20, 21};
bbParamDef(3).name   = 'opt_function';
bbParamDef(3).values = {@opt_mgso};
bbParamDef(4).name   = 'instances';
bbParamDef(4).values = {[1:5 41:50]}; % 31:40]};   % default is [1:5, 41:50]
bbParamDef(5).name   = 'maxfunevals';   % MAXFUNEVALS - 10*dim is a short test-experiment
bbParamDef(5).values = {'250 * dim'};   % increment maxfunevals successively
                                
% Surrogate model parameter lists
sgParamDef(1).name   = 'evalHandle';
sgParamDef(1).values = { @evalHandle };
sgParamDef(2).name   = 'doeHandle';
sgParamDef(2).values = { @doeRandom };
sgParamDef(3).name   = 'sampleHandle';
sgParamDef(3).values = { @sampleSlice };
sgParamDef(4).name   = 'popSize';
sgParamDef(4).values = { '10 * dim' };
sgParamDef(5).name   = 'doe_n';
sgParamDef(5).values = { 'opts.popSize' };
sgParamDef(6).name   = 'doe_minTolX';
sgParamDef(6).values = { 0.002 };
sgParamDef(7).name   = 'sampler_minTolX';
sgParamDef(7).values = { 0.002 };
sgParamDef(8).name   = 'rescaleConds';
sgParamDef(8).values = { {@stopTolX, @stopTolXDistRatio, @stopLowLogpdf} };
sgParamDef(9).name   = 'rescaleCondsParams';
sgParamDef(9).values = { {
  struct('tolerance', 0.1), ...
  struct('tolerance', 0.5), ...
  struct('tolerance', log(0.05)) } };
sgParamDef(10).name   = 'restartConds';
sgParamDef(10).values = { {@stopStallGen} };
sgParamDef(11).name   = 'restartCondsParams';
sgParamDef(11).values = { {struct('generations', 5)} };
sgParamDef(12).name   = 'stopConds';
sgParamDef(12).values = { {@stopTotEvals, @stopTargetReached} };
sgParamDef(13).name   = 'stopCondsParams';
sgParamDef(13).values = { {struct('evaluations', 'maxfunevals'), struct('target', 'fgeneric(''ftarget'')')} };
sgParamDef(14).name   = 'modelOpts';
sgParamDef(14).values = { struct('trainAlgorithm', 'fmincon', ...
  'hyp', struct('cov', [0.1 11], 'mean', 0, 'lik', -4), ...
  'meanFunc', @meanConst, ...
  'covFunc', @covSEiso), ...
  struct( ...
  'trainAlgorithm', 'fmincon', ...
  'hyp', struct( 'cov', log([0.5; 2]), ...
    'mean', 0, ...
    'lik', log(0.01) ), ...
  'meanFunc', @meanConst, ...
  'covFunc', {{@covMaterniso, 5}})
  };
sgParamDef(15).name   = 'observer';
% sgParamDef(15).values = { '@(run) gpedaStep2d(run, fgeneric(''ftarget''))' };
sgParamDef(15).values = { '[]' };

% CMA-ES parameters
cmParamDef(1).name   = 'PopSize';
cmParamDef(1).values = {'(4 + floor(3*log(N)))'}; %, '(8 + floor(6*log(N)))'};
cmParamDef(2).name   = 'Restarts';
cmParamDef(2).values = {4};

% path to current file -- do not change this
pathstr = fileparts(mfilename('fullpath'));
exppath  = [pathstr filesep exp_id];
exppath_short  = pathstr;
[s,mess,messid] = mkdir(exppath);
[s,mess,messid] = mkdir([exppath filesep 'cmaes_results']);
addpath(exppath);

% Save the directory of the experiment data for debugging purposes
sgParamDef(end+1).name = 'experimentPath';
sgParamDef(end).values = { exppath };

save([exppath filesep 'params.mat'], 'bbParamDef', 'sgParamDef', 'cmParamDef', 'exp_id', 'exppath_short', 'logDir');

% run the rest of the scripts generation
generateShellScriptsMetacentrum
