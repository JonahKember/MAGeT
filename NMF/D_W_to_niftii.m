%% Convert W matrix to nifti to visualize components.

fprintf('Converting W matrix to nifti...')

% Specify path.
path = '/home/jkember/scratch/';
output = 'components';

% Define hemisphere labels. 
hemispheres = {'right','left'};

% Load population average.
pop_vol = niftiread([path,'NMF/majority_vote_label.nii']);
info = niftiinfo([path,'NMF/majority_vote_label.nii']);

for hem = 1:2
    for k = 2:7
        % Initialize empty volume.
        vol = zeros(size(pop_vol));

        % Extract indices of voxels.
        idx = find(pop_vol == hem);

        % Load W (voxel x component) matrix output from opnmf.
        load(['/home/jkember/scratch/',hemispheres{hem},'_k',num2str(k),'_nmf_output.mat'])

        % 'Cluster' W matrix (assign each voxel to a component).
        [~,cluster] = max(W,[],2);
        vol(idx) = cluster;

        %  Write to a nifti file.
        niftiwrite(vol,[output,'_k',num2str(k),'_',hemispheres{hem},'.nii'],info)
    end
end