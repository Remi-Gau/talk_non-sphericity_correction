% script to extract data the SPM face repetition event design experiment 
% from FFA region using a neurosynth based ROI

clear 
clc

input_path = fullfile(pwd, 'inputs');
epi_data_path =  fullfile(input_path, 'face_rep', 'RawEPI');


% define inputs
roi_file = 'face_Z_10_k_100.nii';
% roi_file = 'face_FWE_05_k_3000.nii'; % in case we want to extract from voxels that
% survive a FWE p<.05 threshold (but that would be double dipping) ;-p
output_path = fullfile(pwd, 'output');

mask_file = fullfile(input_path, 'face_rep', 'categorical', 'mask.nii');

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

% we will extract data from the smoothed normalised images
files = spm_select('FPList', epi_data_path, '^swar.*.img$'); 

% extract data
Y = spm_get_data(files, XYZ);
save(fullfile(output_path, 'data_FFA.mat'), 'Y')