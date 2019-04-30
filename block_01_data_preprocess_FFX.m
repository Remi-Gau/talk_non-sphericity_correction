% script to get data from SPM website for face event related desgin experiment 
% and run pre-processing and first level

clear 
clc

%% get data
url = 'https://www.fil.ion.ucl.ac.uk/spm/download/data/MoAEpilot/MoAEpilot.bids.zip';
filename = fullfile(pwd, 'inputs', 'MoAEpilot.bids.zip');
fprintf('Downloading Auditory dataset...\n');
outfilename = websave(filename,url);
unzip(filename, fullfile(pwd, 'inputs'))


%% checking what we got
BIDS = spm_BIDS(fullfile(pwd, 'inputs', 'MoAEpilot')); % load data sets

task = spm_BIDS(BIDS, 'tasks')
subject = spm_BIDS(BIDS, 'subjects')
spm_BIDS(BIDS, 'types')
spm_BIDS(BIDS, 'modalities')

func_file = spm_BIDS(BIDS, 'data', 'sub', subject{1}, 'task', task{1}, 'type', 'bold');
metadata = spm_BIDS(BIDS, 'metadata', 'sub', subject{1}, 'task',  task{1}, 'type', 'bold');

anat_file = spm_BIDS(BIDS, 'data', 'sub', subject{1}, 'type', 'T1w');

event_file = spm_BIDS(BIDS, 'data', 'sub', subject{1}, 'type', 'events');
events = spm_load(event_file{1});


%% load preprocess batch and run it
% list all the files in the 4D nifti file
[fullpath, file] = spm_fileparts(func_file{1});
files = spm_select('ExtFPList', fullpath, ['^' file '*.nii$'], Inf);

% identify the SPM directory as it is needed to locate the tissue
% probability maps for the segmentation
spm_dir = spm('dir');

% load the batch witht the right file paths and run it
matlabbatch = preprocess_batch(anat_file{1}, files, spm_dir);
spm('defaults', 'FMRI');
spm_jobman('run', matlabbatch)
clear matlabbatch


%% load subject level GLM batch and run it
output_dir = fullfile(pwd, 'output', 'GLM');
mkdir(output_dir)

% list all the files in the 4D nifti file
[fullpath, file] = spm_fileparts(func_file{1});
files = spm_select('ExtFPList', fullpath, ['^sw' file '*.nii$'], Inf);

% list realign parameter file
rp_file = spm_select('FPList', fullpath, '^rp.*.txt$');

% load GLM batch and run it
matlabbatch = subject_level_glm_batch(output_dir, files, metadata, events, rp_file);

matlabbatch{end+1}={};
matlabbatch{end}.spm.stats.fmri_est.spmmat{1,1} = ...
    fullfile(output_dir, 'SPM.mat');
matlabbatch{end}.spm.stats.fmri_est.method.Classical = 1;
matlabbatch{end}.spm.stats.fmri_est.write_residuals = 1;

% save('matlabbatch.mat', 'matlabbatch')
spm_jobman('run', matlabbatch)



