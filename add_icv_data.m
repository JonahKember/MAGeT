path = 'C:\Users\jonah\Documents\MAGeT\data\';
icv = readtable([path,'icv.csv']);

% Right hemisphere data.
rh = readtable([path,'rh_volumes_demographics.csv']);
rh.icv = zeros(height(rh),1);

for n = 1:height(rh)
    [~,idx] = ismember(rh.src_subject_id(n),icv.id);
    rh.icv(n) = icv.icv_vol(idx);
end
writetable(rh,[path,'rh_volumes_demographics.csv'])

% Left hemispehre data.
lh = readtable([path,'lh_volumes_demographics.csv']);
lh.icv = zeros(height(lh),1);

for n = 1:height(lh)
    [~,idx] = ismember(lh.src_subject_id(n),icv.id);
    lh.icv(n) = icv.icv_vol(idx);
end
writetable(lh,[path,'lh_volumes_demographics.csv'])

