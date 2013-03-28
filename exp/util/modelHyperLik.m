function modelHyperLik(M, lb, ub)
% M     model, already trained from outside
% lb, ub        limits of the parameters to plot, before 
%               taking logarithm of them

gridSize = 51;

% generate mesh of the chosen covarinace parameters
[xy_column xMatrix yMatrix] = grid2d(log(lb), log(ub), gridSize);

% get likelyhood for this mesh values
nlz = arrayfun(@(xm, ym) (gp_hyp(xm, ym, M)), xMatrix, yMatrix);

% plot the likelyhood space contours
subplot(1,2,1);
contour(xMatrix, yMatrix, log(nlz), 50);
hold on;
p1 = M.hyp.cov(1);
p2 = M.hyp.cov(2);
scatter(p1, p2, 'ro');
colorbar;
title('Likelihood of the model parameters M.hyp.cov(1,2)');
hold off;

% plot model prediction (copy/paste from gpedaStep2d.m)
subplot(1,2,2);
[xy_column xx yy] = grid2d([-1 -1], [1 1], gridSize);
n = sqrt(size(xy_column, 1));
xx_o = reshape(xy_column(:, 1), n, n); 
yy_o = reshape(xy_column(:, 2), n, n); 

[m s2] = modelPredict(M, xy_column);
plotErr2(xy_column, m, s2, M.dataset.x, M.dataset.y);
title('Model and dataset');


function nlz = gp_hyp(xm, ym, model)
  hyp = model.hyp;
  % hyp.cov(1:2) = log([xm ym]);
  hyp.cov(1:2) = [xm ym];
  nlz = gp(hyp, model.inffunc, model.meanfunc, model.covfunc, ...
    model.likfunc, model.dataset.x, model.dataset.y);
end

end


  nlz = gp(M_long2.hyp, M_long2.inffunc, M_long2.meanfunc, M_long2.covfunc, ...
    M_long2.likfunc, M_long2.dataset.x, M_long2.dataset.y);

  nlz = gp(M.hyp, M.inffunc, M.meanfunc, M.covfunc, M.likfunc, M.dataset.x, M.dataset.y);


