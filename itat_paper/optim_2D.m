% Sphere 2D v. 1
subplot(1,3,1);
load exp/bbob/output/exp_gpeda_sphere_01/exp_gpeda_sphere_01.mat
idxs = []; for i=1:size(y_evals,1) if (size(y_evals{i},1) == 1) idxs = [idxs i]; end; end;
y_evals(idxs,:) = [];
[M_sph1 meds_sph1] = completeRunStat(y_evals);
ye_sph1 = y_evals;
% semilogy(1:500, meds_sph1, '--k', 'LineWidth', 1);
semilogy(1:10:500, meds_sph1(1:10:500), '.k', 'LineWidth', 1);
hold on;

% Sphere 2D v. 2
load exp/bbob/output/exp_gpeda_sphere_21/exp_gpeda_sphere_21.mat
idxs = []; for i=1:size(y_evals,1) if (size(y_evals{i},1) == 1) idxs = [idxs i]; end; end;
y_evals(idxs,:) = [];
[M_sph2 meds_sph2] = completeRunStat(y_evals);
ye_sph2 = y_evals;
semilogy(1:500, meds_sph2, '-k', 'LineWidth', 1);

% Sphere CMAES 2D
load 'exp/bbob/output/exp_cmaes_sphere_03/exp_cmaes_sphere_03.mat'
idxs = []; for i=1:size(y_evals,1) if (size(y_evals{i},1) == 1) idxs = [idxs i]; end; end;
y_evals(idxs,:) = [];
[M_sph2c meds_sph2c] = completeRunStat(y_evals, 500);
ye_sph2c = y_evals;
% semilogy(1:500, meds_sph2c, ':k', 'LineWidth', 1)
semilogy(1:10:500, meds_sph2c(1:10:500), 'ok', 'LineWidth', 1)

ylabel('f_\Delta');
xlabel('# of function eval.');
title('Sphere in 2D');
legend('MGSO v. 1', 'MGSO v. 2', 'CMA-ES');
axis([0 500 10e-9 10e4]);

hold off;


% Rosenbrock 2D v. 1
subplot(1,3,2);
load exp/bbob/output/exp_gpeda_rosenbrock_01/exp_gpeda_rosenbrock_01.mat
idxs = []; for i=1:size(y_evals,1) if (size(y_evals{i},1) == 1) idxs = [idxs i]; end; end;
y_evals(idxs,:) = [];
[M_ros1 meds_ros1] = completeRunStat(y_evals);
ye_ros1 = y_evals;
% semilogy(1:500, meds_ros1, '--k', 'LineWidth', 1)
semilogy(1:10:500, meds_ros1(1:10:500), '.k', 'LineWidth', 1);
hold on;

% Rosenbrock 2D v. 2
load exp/bbob/output/exp_gpeda_rosenbrock_21/exp_gpeda_rosenbrock_21.mat
idxs = []; for i=1:size(y_evals,1) if (size(y_evals{i},1) == 1) idxs = [idxs i]; end; end;
y_evals(idxs,:) = [];
[M_ros2 meds_ros2] = completeRunStat(y_evals);
ye_ros2 = y_evals;
semilogy(1:500, meds_ros2, '-k', 'LineWidth', 1)

% Rosenbrock CMAES 2D
load exp/bbob/output/exp_cmaes_rosenbrock_03/exp_cmaes_rosenbrock_03.mat
idxs = []; for i=1:size(y_evals,1) if (size(y_evals{i},1) == 1) idxs = [idxs i]; end; end;
y_evals(idxs,:) = [];
[M_ros2c meds_ros2c] = completeRunStat(y_evals, 500);
ye_ros2c = y_evals;
% semilogy(1:500, meds_ros2c, ':k', 'LineWidth', 1)
semilogy(1:10:500, meds_ros2c(1:10:500), 'ok', 'LineWidth', 1)

ylabel('f_\Delta');
xlabel('# of function eval.');
title('Rosenbrock in 2D');
legend('MGSO v. 1', 'MGSO v. 2', 'CMA-ES');
axis([0 500 10e-9 10e4]);
hold off;



% Rastrigin 2D v. 1
subplot(1,3,3);
load exp/bbob/output/exp_gpeda_rastrigin_01/exp_gpeda_rastrigin_01.mat
idxs = []; for i=1:size(y_evals,1) if (size(y_evals{i},1) == 1) idxs = [idxs i]; end; end;
y_evals(idxs,:) = [];
[M_ras1 meds_ras1] = completeRunStat(y_evals);
ye_ras1 = y_evals;
% semilogy(1:500, meds_ras1, '--k', 'LineWidth', 1);
semilogy(1:10:500, meds_ras1(1:10:500), '.k', 'LineWidth', 1);
hold on;

% Rastrigin 2D v. 2
load exp/bbob/output/exp_gpeda_rastrigin_21/exp_gpeda_rastrigin_21.mat
idxs = []; for i=1:size(y_evals,1) if (size(y_evals{i},1) == 1) idxs = [idxs i]; end; end;
y_evals(idxs,:) = [];
[M_ras2 meds_ras2] = completeRunStat(y_evals);
ye_ras2 = y_evals;
semilogy(1:500, meds_ras2, '-k', 'LineWidth', 1);

% Rastrigin CMAES 2D
load exp/bbob/output/exp_cmaes_rastrigin_03/exp_cmaes_rastrigin_03.mat
idxs = []; for i=1:size(y_evals,1) if (size(y_evals{i},1) == 1) idxs = [idxs i]; end; end;
y_evals(idxs,:) = [];
[M_ras2c meds_ras2c] = completeRunStat(y_evals, 500);
ye_ras2c = y_evals;
% semilogy(1:500, meds_ras2c, ':k', 'LineWidth', 1)
semilogy(1:10:500, meds_ras2c(1:10:500), 'ok', 'LineWidth', 1)

ylabel('f_\Delta');
xlabel('# of function eval.');
title('Rastrigin in 2D');
legend('MGSO v. 1', 'MGSO v. 2', 'CMA-ES');
axis([0 500 10e-9 10e4]);
hold off;


% ylabel('f_\Delta');
% xlabel('number of function evaluations');
% 
% title('Medians of best found values in 2D');
% legend(...
%   'Rastrigin',...
%   'Rastrigin CS',...
%   'Rastrigin CMA-ES',...
%   'Rosenbrock',...
%   'Rosenbrock CS',...
%   'Rosenbrock CMA-ES',...
%   'Sphere',...
%   'Sphere CS',...
%   'Sphere CMA-ES',...
%   'Location', 'NorthEast');

% function idxs = getEmtpyIdxs(y_evals)
%   idxs = [];
%   for i=1:size(y_evals,1)
%     if (size(y_evals{i},1) == 1)
%       idxs = [idxs i];
%     end
%   end
% end

