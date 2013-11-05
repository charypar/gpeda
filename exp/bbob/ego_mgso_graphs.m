hold off;

subplot(1,3,1);

load output/exp_gpeda_sphere_33/exp_gpeda_sphere_33.mat
idxs = []; for i=1:size(y_evals,1) if (size(y_evals{i},1) == 1) idxs = [idxs i]; end; end;
y_evals(idxs,:) = [];
[M_sph1 meds_sph1] = completeRunStat(y_evals, 1250);
semilogy(1:20:1250, meds_sph1(1:20:1250), '-r', 'LineWidth', 2);

hold on;

load output/exp_bajego_sphere_33/exp_bajego_sphere_33.mat
idxs = []; for i=1:size(y_evals,1) if (size(y_evals{i},1) == 1) idxs = [idxs i]; end; end;
y_evals(idxs,:) = [];
[M_sph2 meds_sph2] = completeRunStat(y_evals, 1250);
semilogy(1:20:1250, meds_sph2(1:20:1250), '.k', 'LineWidth', 1);

load output/exp_cmaes_sphere_33/exp_cmaes_sphere_33.mat
idxs = []; for i=1:size(y_evals,1) if (size(y_evals{i},1) == 1) idxs = [idxs i]; end; end;
y_evals(idxs,:) = [];
[M_sph3 meds_sph3] = completeRunStat(y_evals, 1250);
semilogy(1:20:1250, meds_sph3(1:20:1250), 'ob', 'LineWidth', 1);

hold off;

title('MGSO and EGO on Sphere 5D, 15 runs');
legend('MGSO', 'EGO');

pause(1);

subplot(1,3,2);

load output/exp_gpeda_rosenbrock_32/exp_gpeda_rosenbrock_32.mat
idxs = []; for i=1:size(y_evals,1) if (size(y_evals{i},1) == 1) idxs = [idxs i]; end; end;
y_evals(idxs,:) = [];
[M_ros1 meds_ros1] = completeRunStat(y_evals, 1250);
semilogy(1:20:1250, meds_ros1(1:20:1250), '-r', 'LineWidth', 2);

hold on;

load output/exp_bajego_rosenbrock_32/exp_bajego_rosenbrock_32.mat
idxs = []; for i=1:size(y_evals,1) if (size(y_evals{i},1) == 1) idxs = [idxs i]; end; end;
y_evals(idxs,:) = [];
[M_ros2 meds_ros2] = completeRunStat(y_evals, 1250);
semilogy(1:20:1250, meds_ros2(1:20:1250), '.k', 'LineWidth', 1);

load output/exp_cmaes_rosenbrock_32/exp_cmaes_rosenbrock_32.mat
idxs = []; for i=1:size(y_evals,1) if (size(y_evals{i},1) == 1) idxs = [idxs i]; end; end;
y_evals(idxs,:) = [];
[M_ros3 meds_ros3] = completeRunStat(y_evals, 1250);
semilogy(1:20:1250, meds_ros3(1:20:1250), 'ob', 'LineWidth', 1);

hold off;

title('MGSO and EGO on Rosenbrock 5D, 15 runs');
legend('MGSO', 'EGO');

pause(1);

subplot(1,3,3);

load output/exp_gpeda_rastrigin_32/exp_gpeda_rastrigin_32.mat
idxs = []; for i=1:size(y_evals,1) if (size(y_evals{i},1) == 1) idxs = [idxs i]; end; end;
y_evals(idxs,:) = [];
[M_ras1 meds_ras1] = completeRunStat(y_evals, 1250);
semilogy(1:20:1250, meds_ras1(1:20:1250), '-r', 'LineWidth', 2);

load output/exp_bajego_rastrigin_32/exp_bajego_rastrigin_32.mat
idxs = []; for i=1:size(y_evals,1) if (size(y_evals{i},1) == 1) idxs = [idxs i]; end; end;
y_evals(idxs,:) = [];
[M_ras2 meds_ras2] = completeRunStat(y_evals, 1250);
hold on;
semilogy(1:20:1250, meds_ras2(1:20:1250), '.k', 'LineWidth', 1);

load output/exp_cmaes_rastrigin_32/exp_cmaes_rastrigin_32.mat
idxs = []; for i=1:size(y_evals,1) if (size(y_evals{i},1) == 1) idxs = [idxs i]; end; end;
y_evals(idxs,:) = [];
[M_ras3 meds_ras3] = completeRunStat(y_evals, 1250);
hold on;
semilogy(1:20:1250, meds_ras3(1:20:1250), 'ob', 'LineWidth', 1);

hold off;

title('MGSO and EGO on Rastrigin 5D, 15 runs');
legend('MGSO', 'EGO');

