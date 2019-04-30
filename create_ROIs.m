% scritps to transform Z-score maps from neurosynth into binary mask
% Adapted from: https://en.wikibooks.org/wiki/SPM/How-to#How_to_remove_clusters_under_a_certain_size_in_a_binary_mask?
%
% Playing around with z (cluster forming threshold) and k (cluster size threshold) values will give you different number of
% clusters

% z = 15;
% k = 50;
% ROI  = 'auditory_association-test_z_FDR_0.01.nii';
% ROIf = 'auditory_Z_15_k_50.nii';

z = 10;
k = 100;
ROI  = 'face_association-test_z_FDR_0.01.nii';
ROIf = 'face_Z_10_k_100.nii';

%%

roi_path = fullfile(pwd, 'inputs');
output_path = fullfile(pwd, 'output');

gunzip(fullfile(roi_path, [ROI '.gz']))

%-Connected Component labelling
V = spm_vol(fullfile(roi_path, ROI));
data = spm_read_vols(V);
[l2, num] = spm_bwlabel(double(data>z),26);
if ~num, warning('No clusters found.'); end

%-Extent threshold, and sort clusters according to their extent
[n, ni] = sort(histc(l2(:),0:num), 1, 'descend');
l  = zeros(size(l2));
n  = n(2:end);
ni = ni(2:end)-1;
ni = ni(n>=k);
n  = n(n>=k);
for i=1:length(n)
    l(l2==ni(i)) = i;
end
clear l2 ni
fprintf('Selected %d clusters (out of %d) in image.\n',length(n),num);

%-Write new image
V.fname = fullfile(output_path, ROIf);
spm_write_vol(V,l~=0); % save as binary image. Remove '~=0' so as to
% have cluster labels as their size.
% or use (l~=0).*dat if input image was not binary
