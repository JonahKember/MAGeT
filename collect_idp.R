collect_idp <- function(path_mni, path_niis, path_masks, path_neighbours) {
  
  # Inputs:
  #
  #   path_mni = Path to MNI152 1mm template.
  #   path_niis = List of paths to .nii images with right/left hippocampus data.
  #   path_masks = List of paths to right/left bounding box .nii images.
  #   path_neighbours = List to .csv with linear indices of each site and its neighbours.
  # 
  # Output:
  #
  # idp = N-region vector with IDP values at each site.
  

  # Transform to MNI-152 space.
  if (!require('RNifti')) install.packages('RNifti')
  
  hemispheres = c('right','left')
  for(hem in 1:length(hemispheres)){
  
    # Create transform.
    transform = paste0(hemispheres[hem],'_transform_')
    cmd = paste0('antsRegistrationSyNQuick.sh',
           ' -d 3',
           ' -f ',path_mni, 
           ' -m ',path_nii,
           ' -x ',path_masks[hem],
           ' -t a',
           ' -o ',transform)
    system(cmd)
    
    # Apply transform.
    output = sub('.nii',paste0('_',hemispheres[hem],'_warped.nii'),path_nii)
    cmd = paste0('antsApplyTransforms',
           ' --input ',path_nii,
           ' --output ',output,
           ' --reference-image ',path_mni,
           ' --transform ', paste0(transform,'0GenericAffine.mat'),
           ' --verbose')
    system(cmd)
  }
  
  ### Collect data.

  # Load neighbours.
  nbs = read.csv(path_neighbours)
  
  # Load right/left volumes, combine into a single tensor.
  vol_r = readNifti(path_niis[1])
  vol_l = readNifti(path_niis[1])
  vol = vol_r[,,] + vol_l[,,]
  
  
  # Initialize idp vector.
  n_sites = dim(nbs)[2]
  idp = matrix(0,n_sites)
  
  # Collect data.
  for(site in 1:n_regions){
    idp[site] = mean(na.omit(vol[nbs[,site]]))
  }
  return(idp)
}


# Example

path_mni = 'C:\\MNI152_T1_1mm_brain.nii'

path_niis = c('C:\\metric_of_interest_right.nii',
              'C:\\metric_of_interest_left.nii')

path_masks = c('C:\\MNI152_bounding_box_right.nii',
               'C:\\MNI152_bounding_box_left.nii')

path_neighbours = 'C:\\neighbours_linear_indices.csv'

collect_idp(path_mni, path_niis, path_masks, path_neighbours)
