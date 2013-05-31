% runs an entire experiment for benchmarking MY_OPTIMIZER
% on the noise-free testbed. fgeneric.m and benchmarks.m
% must be in the path of Matlab/Octave
% CAPITALIZATION indicates code adaptations to be made

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
%  EXPERIMENT GLOBAL SETTINGS
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

exp_id = 'exp_cmaes_sphere_01';

bbobpath = '../vendor/bbob';    % should point to fgeneric.m etc.
datapath = ['output/' exp_id];  % different folder for each experiment
  pathstr = fileparts(mfilename('fullpath'));
  datapath = [pathstr filesep datapath];
  addpath([pathstr filesep bbobpath]);
% opt.inputFormat = 'row';

opt.algName = 'CMA-ES on Sphere';
opt.comments = '';

maxfunevals = '250 * dim'; % 10*dim is a short test-experiment taking a few minutes 
                          % INCREMENT maxfunevals successively to larger value(s)
minfunevals = 'dim + 2';  % PUT MINIMAL SENSIBLE NUMBER OF EVALUATIONS for a restart
maxrestarts = 1e4;        % SET to zero for an entirely deterministic algorithm

dimensions  = [2];    % which dimensions to optimize, subset of [2 3 5 10 20 40];

functions   = [8];    % function ID's to optimize
% functions   = benchmarks('FunctionIndices');

instances = [1:5, 31:40];      % [1:5, 31:40]

opt_function = @opt_cmaes; % function being optimized -- BBOB wrap-around with header
                                % xbest = function( fun, dim, ftarget, maxfunevals )


% runs an entire experiment for benchmarking MY_OPTIMIZER
% on the noise-free testbed. fgeneric.m and benchmarks.m
% must be in the path of Matlab/Octave

more off;  % in octave pagination is on by default

t0 = clock;
rand('state', sum(100 * t0));

results = cell(0);
y_evals = cell(0);

for dim = dimensions            % small dimensions first, for CPU reasons
  % for ifun = benchmarks('FunctionIndices')  % or benchmarksnoisy(...)
  for ifun = functions          % or benchmarksnoisy(...)
    for iinstance = instances   % 15 function instances
      fgeneric('initialize', ifun, iinstance, datapath, opt); 

      % independent restarts until maxfunevals or ftarget is reached
      for restarts = 0:maxrestarts
        if restarts > 0  % write additional restarted info
          fgeneric('restart', 'independent restart')
        end
        [xopt, ilaunch, ye] = opt_function('fgeneric', dim, fgeneric('ftarget'), ...
                     eval(maxfunevals) - fgeneric('evaluations'));
        % we don't have this information from CMA-ES :(
        % results = cat(1,results,res);
        % ye = [res.deltasY res.evaluations];
        y_evals = cat(1,y_evals,ye);

        if fgeneric('fbest') < fgeneric('ftarget') || ...
           fgeneric('evaluations') + eval(minfunevals) > eval(maxfunevals)
          break;
        end  
      end

      disp(sprintf(['  f%d in %d-D, instance %d: FEs=%d with %d restarts,' ...
                    ' fbest-ftarget=%.4e, elapsed time [h]: %.2f'], ...
                   ifun, dim, iinstance, ...
                   fgeneric('evaluations'), ...
                   restarts, ...
                   fgeneric('fbest') - fgeneric('ftarget'), ...
                   etime(clock, t0)/60/60));

      fgeneric('finalize');
    end
    disp(['      date and time: ' num2str(clock, ' %.0f')]);
  end
  disp(sprintf('---- dimension %d-D done ----', dim));
end

save([datapath filesep exp_id '.mat'], 'results', 'y_evals');

