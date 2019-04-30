function plot_GLM_results(name, X, Y, Y_hat, beta, residuals)

% Statistics for our contrast of interest
[t_A1L, p_A1L, df, dferror, std_error] = ...
    stats_GLM(X, mean(beta, 2), mean(residuals, 2));

figure('name', name, 'position', [100 100 1700 800])

colormap('gray')

subplot(2, 4, 1)
imagesc(Y)
title('data: all voxels')
ylabel('time points')
xlabel('voxels')

subplot(2, 4, 2)
imagesc(X)
title('design matrix')
ylabel('time')

subplot(2, 4, 3)
imagesc(beta)
title('beta value')
xlabel('voxels')

subplot(2, 4, 4)
imagesc(residuals)
title('residuals')
ylabel('time points')
xlabel('voxels')


subplot(2, 4, 5)
hold on
plot(mean(Y, 2))
plot(mean(Y_hat, 2), ' or')
ylabel('mean')
axis tight
xlabel('time')
legend({'Y', 'Ŷ'}, 'Location','SouthWest' )
title('data and predicted value: mean across voxels')

% diplay t value
ax = axis;
t = text(size(Y, 1)/2, ...
    ax(3)+.85*(ax(4)-ax(3)), ...
    sprintf('t = %f', t_A1L) );
set(t, 'fontsize', 14);

subplot(2, 4, 6)
imagesc(X)
title('design matrix')
ylabel('time points')

subplot(2, 4, 7)
if size(X,2)>1
    MAX = size(X,2)-.5;
    errorbar(mean(beta(1:end-1,:), 2), std(beta(1:end-1,:), 0, 2), ' o')
else
    MAX = 1.5;
    errorbar(mean(beta, 2), std(beta, 0, 2), ' o')
end

ax = axis;
axis([.5 MAX, ax(3) ax(4)])
title('beta: mean +/- STD across voxels')

subplot(2, 4, 8)
hold on
errorbar(mean(residuals, 2), std(residuals,[],2))
plot(mean(residuals, 2), 'b', 'linewidth', 2)
axis tight
xlabel('time points')
title('residuals: mean across voxels')

end