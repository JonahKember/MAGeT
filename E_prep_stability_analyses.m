%% Prepare stability analyses.

addpath('/home/jkember/scratch/brainlets');

% Specify path.
path = '/home/jkember/scratch/';

% Define hemisphere labels. 
hemispheres = {'right','left'};

% Specify number of splits.
n_splits = 5;

% Load age variable.
load([path,'age.mat']);

%% Define splits by stratifying based on a continuous demographic variable (age).

% Specify number of randomizations for stratification.
n_randomizations = 500;

% Define number of subjects.
n_subj = length(age);

% Define index of middle subject (for splitting data).
mid = floor(n_subj./2);

% Create random splits.
splits = zeros(n_subj,n_randomizations);
for n = 1:n_randomizations
    splits(:,n) = randperm(n_subj);
end

% Calculate quality of splits (absolute value of difference in means of age).
split_qual = zeros(1,n_randomizations);
for n = 1:n_randomizations
    split_1 = splits(1:mid,n);
    split_2 = splits((mid + 1):n_subj,n);
    split_qual(n) = abs(mean(age(split_1)) - mean(age(split_2)));
end

% Find n splits with highest quality.
[~,split_idx] = mink(split_qual,n_splits);
splits = splits(:,split_idx);

%%

% Create new directory.
mkdir([path,'NMF_stability'])

for hem = 1:2
    for k = 2:7

        % Create new directory for given k value.
        mkdir([path,'NMF_stability/k',num2str(k)])

        for split = 1:n_splits

            % Define subjects within each split.
            sA = splits(1:mid,split);
            sB = splits((mid + 1):n_subj,split);

            % Load unnormalized NMF inputs.
            load([path,'/NMF/',hemispheres{hem},'_nmf_input_T1T2_raw.mat'])
            sA_T1T2 = data(:,sA);
            sB_T1T2 = data(:,sB);

            load([path,'/NMF/',hemispheres{hem},'_nmf_input_FA_raw.mat'])
            sA_FA = data(:,sA);
            sB_FA = data(:,sB);
            
            load([path,'/NMF/',hemispheres{hem},'_nmf_input_MD_raw.mat'])
            sA_MD = data(:,sA);
            sB_MD = data(:,sB);
            
            % Normalize each input (separately for each metric and split).
            sA_T1T2 = norm_input(sA_T1T2);
            sB_T1T2 = norm_input(sB_T1T2);
            
            sA_FA = norm_input(sA_FA);
            sB_FA = norm_input(sB_FA);
            
            sA_MD = norm_input(sA_MD);
            sB_MD = norm_input(sB_MD);
            
            % Concatenate all metrics to create single NMF input matrix for each split.
            nmf_input_sA = [sA_T1T2,sA_FA,sA_MD];
            nmf_input_sB = [sB_T1T2,sB_FA,sB_MD];            

            % Run each input through op-NMF, then save.
            [W,H,recon] = opnmf_mem_cobra(nmf_input_sA, k, [], 4,50000,[],[],100,[]);
            save('-v7',[path,'NMF_stability/k',num2str(k),'/','A',num2str(split),'.mat'],'W','H','recon');

            [W,H,recon] = opnmf_mem_cobra(nmf_input_sB, k, [], 4,50000,[],[],100,[]);
            save('-v7',[path,'NMF_stability/k',num2str(k),'/','B',num2str(split),'.mat'],'W','H','recon');

        end
    end
end

%% Define functions.

% Normalize data.
function output = norm_input(data)
    size_data = size(data);
    data = reshape(data, 1, []);
    data = zscore(data);
    data = data + abs(min(min(data)));
    output = reshape(data, size_data(1), size_data(2));
end  