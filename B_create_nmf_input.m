%% Create NMF Input

fprintf('Creating NMF input...')

% Define path
path = '/home/jkember/scratch/NMF/';

% Metric of interest.
metric = {'T1wT2w-outputs','T1wDividedByT2w_warped','T1T2';...
    'FA-outputs','FA_warped','FA';...
    'MD-outputs','MD_warped','MD'};

% Load majority vote label.
mask = niftiread([path,'majority_vote_label.nii']);

% Define hemisphere labels. 
hemispheres = {'right','left'};

% Load participants IDs.
lh = readtable([path,'lh_ids.csv']);
rh = readtable([path,'rh_ids.csv']);
ids_segment = intersect(lh,rh);
ids_metrics = readtable('ids_all_metrics');
ids = intersect(ids_segment,ids_metrics);

%% Testing only- change later.

% Shorten ID list for testing!!!
ids(5:end,:) = [];

%%


% For each metric.
for m = 1:3
    
   % For each hemipshere.
    for hem = 1:2

        % Find voxel indices for given hemisphere.
        mask = niftiread([path,'majority_vote_label.nii']);
        idx = find(mask == hem);

        % Initialize NMF input matrix.
        data = zeros(length(idx),height(ids));

        for s = 1:height(ids)
            fprintf('\nSubject %3.0f',s)

            % Define path to subject's data.
            subj = ids.ID{s};
            microstruc_path = [path,metric{m,1},'/',subj,'_',metric{m,2},'.nii'];

            if ismember(subj,ids.ID)

                % Read data.
                vol = niftiread(microstruc_path);

                % Add subjects data to matrix.
                data(:,s) = vol(idx);

            end
        end

        % Save raw data
        save([path,hemispheres{hem},'_nmf_input_',metric{m,3},'_raw.mat'],'data')

        % Normalize (each metric separately) and shift (so values are positive).
        size_data = size(data);
        data = reshape(data, 1, []);
        data = zscore(data);
        data = data + abs(min(min(data)));
        data = reshape(data, size_data(1), size_data(2));

        % Save
        save([path,hemispheres{hem},'_nmf_input_',metric{m,3},'.mat'],'data')
    end
end

% Concatenate all metrics together and save.
for hem = 1:2
    all_data = [];
    load([path,hemispheres{hem},'_nmf_input_',metric{1,3},'.mat'])
    all_data = [all_data,data]; %#ok<AGROW>

    load([path,hemispheres{hem},'_nmf_input_',metric{2,3},'.mat'])
    all_data = [all_data,data]; %#ok<AGROW>

    load([path,hemispheres{hem},'_nmf_input_',metric{3,3},'.mat'])
    all_data = [all_data,data]; %#ok<AGROW>

    save([path,hemispheres{hem},'_nmf_input.mat'],'all_data')
end