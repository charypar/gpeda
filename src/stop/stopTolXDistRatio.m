function tf = stopTolXDistRatio(run, opts)

tolDistRatio = run.attempts{run.attempt}.tolXDistRatios(end);

tf = tolDistRatio < opts.tolerance;
