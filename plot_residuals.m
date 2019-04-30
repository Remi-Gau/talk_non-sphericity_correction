function plot_residuals(name, residuals)
% some vizualisation of the residuals

if(size(residuals,2)<2)
    warning('Some plots will not work because they need more than one voxel.')
end

figure('Name', ['Residuals: ' name], 'position', [100 100 1700 800])

% matrix of residuals
subplot(321)
imagesc(residuals)
title('residuals')
ylabel('time points')
xlabel('voxels')

% 'covariance of the residuals'
subplot(322)
imagesc(residuals*residuals')
axis square
axis tight
title('covariance of the residuals over time')

% compute autocorrelation of the residual for each voxel
for iVox = 1:size(residuals, 2)
    [AutoCorrFunc(iVox,:), lags] = xcorr(residuals(:,iVox), 'coeff');
end

% compute power spectrum of the residuals for each voxel
gX = compute_power_spectrum(residuals);

% for the rest we will plot only the average time course of the residuals
residuals = mean(residuals, 2);

% plot distribution (over time) ofthe mean (over voxels)  of the residuals 
subplot(323)
hold on
hist(residuals, 30)
ax = axis;
plot([mean(residuals) mean(residuals)], [ax(3) ax(4)], 'r')
title('residuals distribution')

% vizually assess normality of the residuals
subplot(324)
normplot(residuals);

% plots mean +/- STD (over voxels) autocorrelation of the residuals
subplot(325)
hold on
q = ceil(size(lags,2)/2); % results is symmetrical so  we only plot half
errorbar(lags(q:end), mean(AutoCorrFunc(:,q:end)), std(AutoCorrFunc(:,q:end)))
plot(lags(q:end), mean(AutoCorrFunc(:,q:end)), 'b', 'linewidth', 2)
ylabel('Autocorrelation')
axis tight

% plots mean +/- STD (over voxels) power spectrum of the residuals
subplot(326)
hold on

q = ceil(size(gX,2)/2); % results is symmetrical so  we only plot half
Hz = linspace(0,q,q); % to get the frequency for the legend

mean_spectrum = mean(gX(:,1:q));
std_spectrum = std(gX(:,1:q), [], 1);

errorbar(Hz, mean_spectrum, std_spectrum);
plot(Hz, mean_spectrum, 'b', 'linewidth', 2)
axis([0 q 0 max(mean_spectrum+std_spectrum)])
title('Frequency domain');
xlabel('Frequency (Hz)')
ylabel('Relative spectral density')
axis tight


end