load /mnt/win/new/doc/skola/phd/2013/09_itat/sampling_results_01.mat

subplot(1,2,1)
boxplot(times_5D');
axis([0.5 2.5 0 82]);
set(gca,'XTick',[1 2]);
set(gca,'XTickLabel',{'Gibbs';'slice'});
ylabel('time [s]');

subplot(1,2,2)
boxplot(popsize_5D');
axis([0.5 2.5 0 53]);
set(gca,'XTick',[1 2]);
set(gca,'XTickLabel',{'Gibbs';'slice'});
ylabel('number of generated samples (out of 50)');

filename = 'sampling_times_5D_v2';
fhandle = '-f1';
set(gcf,'PaperUnits','centimeters')
  
set(gcf,'PaperSize',[10 8]);              % sampling times
set(gcf,'PaperOrientation','portrait')
set(gcf,'PaperPosition',[-0.7 -0.7 11.5 9]);    % sampling times
print(fhandle, '-dpdf', [filename '.pdf']);
print(fhandle, '-dpng', [filename '_.png']);
print(fhandle, '-deps', [filename '.eps']);

