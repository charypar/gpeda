% Sphere 10D
subplot(1,3,1);
load exp/bbob/output/exp_gpeda_sphere_25/exp_gpeda_sphere_25.mat
idxs = []; for i=1:size(y_evals,1) if (size(y_evals{i},1) == 1) idxs = [idxs i]; end; end;
y_evals(idxs,:) = [];
[M_sph5 meds_sph5] = completeRunStat(y_evals, 2500);
ye_sph5 = y_evals;
semilogy(1:2500, meds_sph5, '-k', 'LineWidth', 1);
hold on;

% Sphere CMAES 10D
load exp/bbob/output/exp_cmaes_sphere_05/exp_cmaes_sphere_05.mat
idxs = []; for i=1:size(y_evals,1) if (size(y_evals{i},1) == 1) idxs = [idxs i]; end; end;
y_evals(idxs,:) = [];
[M_sph5c meds_sph5c] = completeRunStat(y_evals, 2500);
ye_sph5c = y_evals;
% semilogy(1:2500, meds_sph5c, '-.k', 'LineWidth', 1);
semilogy(1:50:2500, meds_sph5c(1:50:2500), 'ok', 'LineWidth', 1);

ylabel('f_\Delta');
xlabel('# of function eval.');
title('Sphere in 10D');
legend('MGSO v. 2', 'CMA-ES');
axis([0 2500 10e-5 10e4]);
hold off;

% Rosenbrock 10D
subplot(1,3,2);
load exp/bbob/output/exp_gpeda_rosenbrock_25/exp_gpeda_rosenbrock_25.mat
idxs = []; for i=1:size(y_evals,1) if (size(y_evals{i},1) == 1) idxs = [idxs i]; end; end;
y_evals(idxs,:) = [];
[M_ros5 meds_ros5] = completeRunStat(y_evals, 2500);
ye_ros5 = y_evals;
semilogy(1:2500, meds_ros5, '-k', 'LineWidth', 1)
hold on;

% Rosenbrock CMAES 10D
load exp/bbob/output/exp_cmaes_rosenbrock_05/exp_cmaes_rosenbrock_05.mat
idxs = []; for i=1:size(y_evals,1) if (size(y_evals{i},1) == 1) idxs = [idxs i]; end; end;
y_evals(idxs,:) = [];
[M_ros5c meds_ros5c] = completeRunStat(y_evals, 2500);
ye_ros5c = y_evals;
% semilogy(1:2500, meds_ros5c, '-.r', 'LineWidth', 1)
semilogy(1:50:2500, meds_ros5c(1:50:2500), 'ok', 'LineWidth', 1);

ylabel('f_\Delta');
xlabel('# of function eval.');
title('Rosenbrock in 10D');
legend('MGSO v. 2', 'CMA-ES');
axis([0 2500 10e-5 10e4]);
hold off;


% Rastrigin 10D
subplot(1,3,3);
load exp/bbob/output/exp_gpeda_rastrigin_25/exp_gpeda_rastrigin_25.mat
idxs = []; for i=1:size(y_evals,1) if (size(y_evals{i},1) == 1) idxs = [idxs i]; end; end;
y_evals(idxs,:) = [];
[M_ras5 meds_ras5] = completeRunStat(y_evals, 2500);
ye_ras5 = y_evals;
semilogy(1:2500, meds_ras5, '-k', 'LineWidth', 1);
hold on;

% Rastrigin CMAES 10D
load exp/bbob/output/exp_cmaes_rastrigin_06/exp_cmaes_rastrigin_06.mat
idxs = []; for i=1:size(y_evals,1) if (size(y_evals{i},1) == 1) idxs = [idxs i]; end; end;
y_evals(idxs,:) = [];
[M_ras5c meds_ras5c] = completeRunStat(y_evals, 2500);
ye_ras5c = y_evals;
% semilogy(1:2500, meds_ras5c, '-.m', 'LineWidth', 1)
semilogy(1:50:2500, meds_ras5c(1:50:2500), 'ok', 'LineWidth', 1)

ylabel('f_\Delta');
xlabel('# of function eval.');
title('Rastrigin in 10D');
legend('MGSO v. 2', 'CMA-ES');
axis([0 2500 10e-5 10e4]);
hold off;


% ylabel('f_\Delta');
% xlabel('number of function evaluations');
% 
% title('Medians of best found values in 10D');
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

