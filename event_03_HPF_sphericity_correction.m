clear
close all
clc

input_path = fullfile(pwd, 'inputs');
output_path = fullfile(pwd, 'output');
load(fullfile(output_path, 'data_FFA.mat'), 'Y')
Y = Y/spm_global(Y)*100;

%% plot power spectrum of the data
figure('name', 'data: time course and power spectrum', 'position', [100 100 1700 800])

% plot time course +/- STD
subplot(1,2,1)
hold on
errorbar(mean(Y, 2), std(Y, [], 2))
plot(mean(Y, 2), 'b', 'linewidth', 2)
axis tight

% compute power spectrum for each voxel and then plot the mean
subplot(1,2,2)
gX = compute_power_spectrum(Y);
q = ceil(size(gX,2)/2);
Hz = linspace(0,q,q);

hold on
mean_spectrum = mean(gX(:,1:q));
std_spectrum = std(gX(:,1:q), [], 1);
errorbar(Hz, mean_spectrum, std_spectrum);
plot(Hz, mean_spectrum, 'b', 'linewidth', 2)
axis([0 q 0 max(mean_spectrum+std_spectrum)])
title('Frequency domain');
xlabel('Frequency (Hz)')
ylabel('Relative spectral density')


%% GLM with regressor made by SPM and constant

% get design matrix
load(fullfile(input_path, 'face_rep', 'categorical', 'SPM.mat'))
X = SPM.xX.X;
X = X(:,1:3:12); % only take the HRF convovled regressor
X(:,end+1) = ones(size(X,1), 1); % add constant

% run GLM
[beta, Y_hat, residuals] = run_GLM(X, Y);

% plot results
name = 'SPM convolved regressor';
plot_GLM_results(name, X, Y, Y_hat, beta, residuals)
plot_residuals(name, residuals)


%% adding a rough linear component to try to account for low frequency drift
X = SPM.xX.X;
X = [ X(:,1:3:12), ... % SPM convolved regressor
     (1:size(X,1))'/size(X,1) ... % linear drift
     ones(size(X,1), 1)]; % constant

% run GLM
[beta, Y_hat, residuals] = run_GLM(X, Y);

% plot results
name = 'SPM convolved regressor + linear drift';
plot_GLM_results(name, X, Y, Y_hat, beta, residuals)
plot_residuals(name, residuals)


%% using SPM DCT to account for low frequency drift
% get SPM high pass filter (discrete cosign transform)
X = SPM.xX.X;
DCT = SPM.xX.K.X0;
X = [X(:,1:3:12), ... % SPM convolved regressor
     DCT ... % linear drift
     ones(size(X,1), 1)]; % constant
 
 % run GLM
[beta, Y_hat, residuals] = run_GLM(X, Y);

% plot results
name = 'SPM convolved regressor + linear drift';
plot_GLM_results(name, X, Y, Y_hat, beta, residuals)
plot_residuals(name, residuals)


%% same but with motion regressors added
% get SPM high pass filter (discrete cosign transform)
X = SPM.xX.X;
DCT = SPM.xX.K.X0;
X = [X(:,[ 1:3:12 13:end-1 ]), ... % SPM convolved regressor
     DCT ... % linear drift
     ones(size(X,1), 1)]; % constant
 
 % run GLM
[beta, Y_hat, residuals] = run_GLM(X, Y);

% plot results
name = 'SPM convolved regressor + linear drift + motion regressors';
plot_GLM_results(name, X, Y, Y_hat, beta, residuals)
plot_residuals(name, residuals)


%%
% SPM.xX.pKX - pseudoinverse of K*W*X, computed by spm_sp
% SPM.xX.K - cell. low frequency confound: high-pass cutoff (secs)
% SPM.xX.xKXs - space structure for K*W*X, the 'filtered and whitened' design matrix
% SPM.xX.xKXs.X - Mtx - matrix of trials and betas (columns) in each trial
% SPM.xX.nKX - design matrix (xX.xKXs.X) scaled for display (see spm_DesMtx('sca',... for details) 

W = SPM.xX.W; % Get weight/whitening matrix:  W*W' = inv(V)
KWY = spm_filter(SPM.xX.K, W*Y); % Whiten/Weight data and remove filter confounds
beta = SPM.xX.pKX * KWY; % Weighted Least Squares estimation
residuals      = spm_sp('r',SPM.xX.xKXs,KWY); %-Residuals
KWY = Y - residuals;

name = 'after whitening';
plot_GLM_results(name, SPM.xX.xKXs.X, W*Y, Y_hat, beta, residuals)
plot_residuals(name, residuals)