load exp/bbob/output/exp_gpeda_rastrigin_01/exp_gpeda_rastrigin_01.mat
[M_ras meds_ras] = completeRunStat(y_evals);
ye_ras = y_evals;
load exp/bbob/output/exp_gpeda_rosenbrock_01/exp_gpeda_rosenbrock_01.mat
y_evals([2 3 5 7 9 11 13 15 17 20 22 24 26 28],:) = [];
[M_ros meds_ros] = completeRunStat(y_evals);
ye_ros = y_evals;
load exp/bbob/output/exp_gpeda_sphere_01/exp_gpeda_sphere_01.mat
y_evals([3 5 7 9 12 14 16 18 21 23 25 27],:) = [];
[M_sph meds_sph] = completeRunStat(y_evals);
ye_sph = y_evals

semilogy(1:500, meds_ras, '-.m', 'LineWidth', 1)
hold on;
semilogy(1:500, meds_ros, '--r', 'LineWidth', 1)
semilogy(1:500, meds_sph, '-b', 'LineWidth', 1)

% int = 10:50:500;
% semilogy(int, meds_ras(int), 'og', 'MarkerSize', 7)
% semilogy(int, meds_ros(int), '*r', 'MarkerSize', 7)
% semilogy(int, meds_sph(int), '+b', 'MarkerSize', 7)
% title('Medians of best found values in 2D');
ylabel('f_\Delta');
xlabel('number of function evaluations');
legend('Rastrigin', 'Rosenbrock', 'Sphere', 'Location', 'SouthWest');
