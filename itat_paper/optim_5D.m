% Sphere 5D
subplot(1,3,1);
load exp/bbob/output/exp_gpeda_sphere_23/exp_gpeda_sphere_23.mat
idxs = []; for i=1:size(y_evals,1) if (size(y_evals{i},1) == 1) idxs = [idxs i]; end; end;
y_evals(idxs,:) = [];
[M_sph5 meds_sph5] = completeRunStat(y_evals, 1250);
ye_sph5 = y_evals;
semilogy(1:1250, meds_sph5, '-k', 'LineWidth', 1);
hold on;

% Sphere CMAES 5D
load exp/bbob/output/exp_cmaes_sphere_04/exp_cmaes_sphere_04.mat
idxs = []; for i=1:size(y_evals,1) if (size(y_evals{i},1) == 1) idxs = [idxs i]; end; end;
y_evals(idxs,:) = [];
[M_sph5c meds_sph5c] = completeRunStat(y_evals, 1250);
ye_sph5c = y_evals;
% semilogy(1:1250, meds_sph5c, '-.k', 'LineWidth', 1);
semilogy(1:25:1250, meds_sph5c(1:25:1250), 'ok', 'LineWidth', 1);

ylabel('f_\Delta');
xlabel('# of function eval.');
title('Sphere in 5D');
legend('MGSO v. 2', 'CMA-ES');
axis([0 1250 10e-6 10e3]);
hold off;

% Rosenbrock 5D v. 1
subplot(1,3,2);
load exp/bbob/output/exp_gpeda_rosenbrock_23/exp_gpeda_rosenbrock_23.mat
idxs = []; for i=1:size(y_evals,1) if (size(y_evals{i},1) == 1) idxs = [idxs i]; end; end;
y_evals(idxs,:) = [];
[M_ros5 meds_ros5] = completeRunStat(y_evals, 1250);
ye_ros5 = y_evals;
semilogy(1:1250, meds_ros5, '-k', 'LineWidth', 1)
hold on;

% Rosenbrock CMAES 5D
load exp/bbob/output/exp_cmaes_rosenbrock_04/exp_cmaes_rosenbrock_04.mat
idxs = []; for i=1:size(y_evals,1) if (size(y_evals{i},1) == 1) idxs = [idxs i]; end; end;
y_evals(idxs,:) = [];
[M_ros5c meds_ros5c] = completeRunStat(y_evals, 1250);
ye_ros5c = y_evals;
% semilogy(1:1250, meds_ros5c, '-.r', 'LineWidth', 1)
semilogy(1:25:1250, meds_ros5c(1:25:1250), 'ok', 'LineWidth', 1);

ylabel('f_\Delta');
xlabel('# of function eval.');
title('Rosenbrock in 5D');
legend('MGSO v. 2', 'CMA-ES');
axis([0 1250 10e-6 10e3]);
hold off;


% Rastrigin 5D v. 1
subplot(1,3,3);
load exp/bbob/output/exp_gpeda_rastrigin_23/exp_gpeda_rastrigin_23.mat
idxs = []; for i=1:size(y_evals,1) if (size(y_evals{i},1) == 1) idxs = [idxs i]; end; end;
y_evals(idxs,:) = [];
[M_ras5 meds_ras5] = completeRunStat(y_evals, 1250);
ye_ras5 = y_evals;
semilogy(1:1250, meds_ras5, '-k', 'LineWidth', 1);
hold on;

% Rastrigin CMAES 5D
load exp/bbob/output/exp_cmaes_rastrigin_04/exp_cmaes_rastrigin_04.mat
idxs = []; for i=1:size(y_evals,1) if (size(y_evals{i},1) == 1) idxs = [idxs i]; end; end;
y_evals(idxs,:) = [];
[M_ras5c meds_ras5c] = completeRunStat(y_evals, 1250);
ye_ras5c = y_evals;
% semilogy(1:1250, meds_ras5c, '-.m', 'LineWidth', 1)
semilogy(1:25:1250, meds_ras5c(1:25:1250), 'ok', 'LineWidth', 1)

ylabel('f_\Delta');
xlabel('# of function eval.');
title('Rastrigin in 5D');
legend('MGSO v. 2', 'CMA-ES');
axis([0 1250 10e-6 10e3]);
hold off;


% ylabel('f_\Delta');
% xlabel('number of function evaluations');
% 
% title('Medians of best found values in 5D');
% legend(...
%   'Rastrigin CS',...
%   'Rastrigin CMA-ES',...
%   'Rosenbrock CS',...
%   'Rosenbrock CMA-ES',...
%   'Sphere CS',...
%   'Sphere CMA-ES',...
%   'Location', 'NorthEast');
% 
% hold off;

% function idxs = getEmtpyIdxs(y_evals)
%   idxs = [];
%   for i=1:size(y_evals,1)
%     if (size(y_evals{i},1) == 1)
%       idxs = [idxs i];
%     end
%   end
% end

