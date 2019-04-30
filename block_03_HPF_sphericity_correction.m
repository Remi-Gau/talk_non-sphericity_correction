clear
close all
clc

output_path = fullfile(pwd, 'output');
load(fullfile(output_path, 'data_A1.mat'), 'Y')
Y = Y/spm_global(Y)*100;

% get info about data set
BIDS = spm_BIDS(fullfile(pwd, 'inputs', 'MoAEpilot')); % load data sets
subject = spm_BIDS(BIDS, 'subjects');
task = spm_BIDS(BIDS, 'tasks');
event_file = spm_BIDS(BIDS, 'data', 'sub', subject{1}, 'type', 'events');
metadata = spm_BIDS(BIDS, 'metadata', 'sub', subject{1}, 'task',  task{1}, 'type', 'bold');

% get stimulus onset time
events = spm_load(event_file{1});

% convert onsets and duration in scan units
events.onset = events.onset/metadata.RepetitionTime;
events.duration = events.duration/metadata.RepetitionTime;


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
q = size(gX,2)/2;
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


%% GLM with box car regressor

% create block regressor
box_car_regressor = zeros(size(Y,1),1);
for i=1:length(events.onset)
    box_car_regressor(events.onset(i):(events.onset(i)+events.duration(i)))=1;
end
X = box_car_regressor;

% run GLM
[beta, Y_hat, residuals] = run_GLM(X, Y);

% plot results
name = 'unconvolved regressor no constant';
plot_GLM_results(name, X, Y, Y_hat, beta, residuals)
plot_residuals(name, residuals)


%% GLM with box car regressor and constant

% create block regressor
box_car_regressor = zeros(size(Y,1),1);
for i=1:length(events.onset)
    box_car_regressor(events.onset(i):(events.onset(i)+events.duration(i)))=1;
end
X = box_car_regressor;
X(:,end+1) = ones(size(X,1), 1); % add constant

% run GLM
[beta, Y_hat, residuals] = run_GLM(X, Y);

% plot results
name = 'unconvolved regressor';
plot_GLM_results(name, X, Y, Y_hat, beta, residuals)
plot_residuals(name, residuals)


%% GLM with convolved box car regressor and constant

% Basis function
xBF.dt = metadata.RepetitionTime; % Temporal resolution in seconds of the informed basis set to create
xBF.name = 'hrf (with time and dispersion derivatives)';
xBF.length = 32;
xBF.order = 1;
xBF = spm_get_bf(xBF); 

X = conv(xBF.bf(:,1), box_car_regressor);
X = X(1:size(Y,1),:);
X(:,end+1) = ones(size(X,1), 1); % add constant

% run GLM
[beta, Y_hat, residuals] = run_GLM(X, Y);

% plot results
name = 'convolved regressor';
plot_GLM_results(name, X, Y, Y_hat, beta, residuals)
plot_residuals(name, residuals)


%% GLM with regressor made by SPM and constant
% convolution is done at higher temporal resolution

% get design matrix
load(fullfile(output_path, 'GLM', 'SPM.mat'))
X = SPM.xX.X;
X = X(:,1); % only take the convovled regressor
X(:,end+1) = ones(size(X,1), 1); % add constant

% run GLM
[beta, Y_hat, residuals] = run_GLM(X, Y);

% plot results
name = 'SPM convolved regressor';
plot_GLM_results(name, X, Y, Y_hat, beta, residuals)
plot_residuals(name, residuals)


%% adding a rough linear component to try to account for low frequency drift
X = SPM.xX.X;
X = [X(:,1), ... % SPM convolved regressor
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
X = [X(:,1), ... % SPM convolved regressor
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
X = [X(:,1:end-1), ... % SPM convolved regressor
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

% W = SPM.xX.W; % Get weight/whitening matrix:  W*W' = inv(V)
% KWY = spm_filter(SPM.xX.K, W*Y); % Whiten/Weight data and remove filter confounds
% beta = SPM.xX.pKX * KWY; % Weighted Least Squares estimation
% residuals      = spm_sp('r',SPM.xX.xKXs,KWY); %-Residuals
% KWY = Y - residuals;
% 
% plot_GLM_results(name, SPM.xX.xKXs.X, W*Y, Y_hat, beta, residuals)
% plot_residuals(name, residuals)