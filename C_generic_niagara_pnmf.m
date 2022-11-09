%% Run opNMF

fprintf('Running op-NMF...')

addpath('/home/jkember/scratch/brainlets');
path = '/home/jkember/scratch/NMF/';

% Define hemisphere labels. 
hemispheres = {'right','left'};

% For variable number of components...
for k = 2:7
    % For each hemishere...
    for hem = 1:2
        % Load input.
        load([path,hemispheres{hem},'_nmf_input.mat']);

        % Run opNMF.
        [W,H,recon] = opnmf_mem_cobra(all_data, k, [], 4,50000,[],[],100,[]);

        % Save output.
        save('-v7',['/home/jkember/scratch/',hemispheres{hem},'_k',num2str(k),'_nmf_output.mat'],'W','H','recon');
    end
end
