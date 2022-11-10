%% Create majority vote nifti

fprintf('Creating majority vote label...')

% Specify path
path = '/home/jkember/scratch/NMF/';

% Load IDs
lh = readtable([path,'lh_ids.csv']);
rh = readtable([path,'rh_ids.csv']);
ids = intersect(lh,rh);

% Initialize volumes and subject count
ga_vol_r = zeros(165,201,171);
ga_vol_l = zeros(165,201,171);
n_subj = 0;

%% Testing only- change later.
% Shorten ID list for testing!!!
ids(5:end,:) = [];

%%

for s = 1:height(ids)

    % Define subject
    subj = ids.ID{s};
    fprintf('\nSubject # %3.0f',s)
    
    % Check if both left and right volumes exist
    if exist([path,'MAGeT-right-outputs/',subj,'_MAGeT_warped.nii.gz']) %#ok<EXIST>
        if exist([path,'MAGeT-right-outputs/',subj,'_MAGeT_warped.nii.gz']) %#ok<EXIST>

            % Count number of subjects w/ data for both hemipsheres
            n_subj = n_subj + 1;

            % Load volumes
            r_vol = niftiread([path,'MAGeT-right-outputs/',subj,'_MAGeT_warped.nii.gz']);
            l_vol = niftiread([path,'MAGeT-left-outputs/',subj,'_MAGeT_warped.nii.gz']);

            % Binarize volumes
            r_vol(r_vol > 0) = 1;
            l_vol(l_vol > 0) = 1;
            
            % Add to grand average
            ga_vol_r = ga_vol_r + r_vol;
            ga_vol_l = ga_vol_l + l_vol;

        end
    end
end

fprintf('\nCreating grand-average...')
% Majority vote
ga_vol_r(ga_vol_r <= floor(.5*n_subj)) = 0;
ga_vol_l(ga_vol_l <= floor(.5*n_subj)) = 0;

ga_vol_r(ga_vol_r > floor(.5*n_subj)) = 1;
ga_vol_l(ga_vol_l > floor(.5*n_subj)) = 2;

% Combine left and right hemispheres (right = 1, left = 2).
ga_vol = ga_vol_r + ga_vol_l;

% Save
fprintf('\nSaving...')
info = niftiinfo([path,'MAGeT-right-outputs/',subj,'_MAGeT_warped.nii.gz']);
niftiwrite(ga_vol,[path,'majority_vote_label.nii'],info)
fprintf('\nNumber of subjects: %3.0f\n',n_subj)

