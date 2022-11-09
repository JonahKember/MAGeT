# MAGeT

# NMF (non-negative matrix factorization)

A_create_majority_vote_label.mat
-Create hippocampus mask in population space.

B_create_nmf_input.mat
-Save both raw and normalized inputs, so that data can be normalized separately during stability analyses.

C_generic_niagara_pnmf.mat
-Apply op-NMF to data, both left/right hemispheres, various k values (2:7), save outputs. 

D_W_to_niftii.mat
-'Cluster' voxels (i.e., assign each voxel to its maximum component), then save as a nifti file for visualization.

E_prep_stability_analyses
-Split the NMF input data (stratified by age).
-Normalize the splits, then run through Raihann's op-NMF script.
-Save the outputs in the format expected by compute_stability_corr.py:

  For k = 2:
  /output_dir_1/
    a0.mat
    b0.mat
    a1.mat
    b1.mat
    ...
