% runs an entire experiment for benchmarking MY_OPTIMIZER
% on the noise-free testbed. fgeneric.m and benchmarks.m
% must be in the path of Matlab/Octave

more off;  % in octave pagination is on by default

t0 = clock;
rand('state', sum(100 * t0));

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
        opt_function('fgeneric', dim, fgeneric('ftarget'), ...
                     eval(maxfunevals) - fgeneric('evaluations'));

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
