function stop = stopLowLogpdf(run, opts)

  maxLogPdf = run.attempts{run.attempt}.maxLogPdf;

  stop = maxLogPdf < opts.tolerance;
