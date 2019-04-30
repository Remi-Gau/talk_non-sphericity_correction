% script to extract data the SPM auditory block design experiment 
% from auditory region using a neurosynth based ROI

clear 
clc

% define inputs
roi_file = 'auditory_Z_15_k_50.nii';
% roi_file = 'auditory_FWE_05.nii'; % in case we want to extract from voxels that
% survive a FWE p<.05 threshold (but that would be double dipping) ;-p
output_path = fullfile(pwd, 'output');

mask_file = fullfile(output_path, 'GLM', 'mask.nii');

BIDS = spm_BIDS(fullfile(pwd, 'inputs', 'MoAEpilot')); % load data sets

% making sure that images have have the same dimension
flags.interp = 0; % to make sure we use nearest neighbour interpolation because we are reslicing a binary image
spm_reslice({ mask_file ; fullfile(output_path, roi_file) }, flags)
roi_file = ['r' roi_file];

% get info about ROI
ROI = spm_read_vols( spm_vol( fullfile(output_path, roi_file) ),1);
indx = find(round(ROI) > 0);
[x,y,z] = ind2sub(size(ROI),indx);
XYZ = [x y z]'; %list all the voxels to 
clear x y z indx Y

% get info about dataset
task = spm_BIDS(BIDS, 'tasks');
subject = spm_BIDS(BIDS, 'subjects');
func_file = spm_BIDS(BIDS, 'data', 'sub', subject{1}, 'task', task{1}, 'type', 'bold');
[fullpath, file] = spm_fileparts(func_file{1});

% we will extract data from the smoothed normalised images
files = spm_select('ExtFPList', fullpath, ['^sw' file '*.nii$'], Inf); 

% extract data
Y = spm_get_data(files, XYZ);
save(fullfile(output_path, 'data_A1.mat'), 'Y')