function myprint(filename, fhandle)

  % Print Graph in PDF, PNG and EPS

  if (nargin < 2 || isempty(fhandle))
    fhandle = '-f1';
  end

  set(gcf,'PaperUnits','centimeters')
  set(gcf,'PaperSize',[10 9.2]);
  % for wide pictures:
  % set(gcf,'PaperSize',[10 19]);
  set(gcf,'PaperOrientation','portrait')
  % set(gcf,'PaperPosition',[0 4 14 10]);
  % set(gcf,'PaperPosition',[0.5 4.5 13 9]);
  % for wide pictures:
  set(gcf,'PaperPosition',[-0.5 -0.4 11 10]);
  print(fhandle, '-dpdf', [filename '.pdf']);
  print(fhandle, '-dpng', [filename '_.png']);
  print(fhandle, '-deps', [filename '.eps']);


