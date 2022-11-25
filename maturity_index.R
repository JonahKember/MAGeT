maturity_idx <- function(X, y, n_perms, p_val, path) {
  
  # Inputs:
  #   X = n x p matrix (input variables).
  #   y = n x 1 matrix (output variable; i.e., Age).
  #   n_perms = Number of permutations for significance testing and bootstrapping.
  #   p_val = Significance threshold (Monte-Carlo) for permutation testing (i.e., .05).
  #   path = Directory for plots to be saved.
  
  # Outputs:
  #   $bs_ratio = Significance values (bootstrapped ratios) for each feature in X.
  #   $lv_weights = Latent variable weights (how strongly each feature in X loads onto the latent variable).
  #   $sig = Whether empirical singular value is outside specified threshold (Logical).
  #   $lv_scores = Latent variable scores.
  #   $X_tot_var = Total variance accounted for in X.
  #   $y_tot_var = Total variance accounted for in y.
  
  #######################
  ### Set-up
  #######################
  
  # Initialize list for results
  results = list(1)
  
  # Set seed for replication
  set.seed(0)
  
  # Define z-score function
  z_score = function(x) {(x - mean(x, na.rm = T))/sd(x, na.rm = T)}
  
  # Ensure data is in a matrix.
  X = as.matrix(X)
  
  # Define variable names
  names = colnames(X)
  
  # Z-score empirical X
  X_emp = apply(X,2,z_score)
  
  # Perform singular value decomposition of correlation vector
  svd_emp = svd(cor(y,X_emp))
  sv_emp = svd_emp$d
  
  # Ensure proper sign (i.e., if correlation between LV and y is negative, flip)
  if(cor(as.vector(t(svd_emp$v) %*% t(X_emp)),y) < 0){
    svd_emp$v = -svd_emp$v
  }
  
  results$lv_weights = svd_emp$v
  
  #######################
  ### Permutation testing
  #######################
  
  # Initialize matrix to track singular values of synthetic data
  syn_vars = matrix(0,n_perms)
  
  for(perm in 1:n_perms){
    
    # Shuffle rows of X, define as X_syn
    resamp_idx = sample(1:length(y), replace = F)
    X_syn = X[resamp_idx,]
    
    # Z-score synthetic X
    X_syn = apply(X_syn,2,z_score)
    
    # Calculate and track the SV of X_syn
    svd_syn =  svd(cor(y,X_syn))
    syn_vars[perm] = svd_syn$d
  }
  
  # Calculate Monte-Carlo p-value
  results$sig = sv_emp > quantile(syn_vars,(1 - p_val))
  
  #######################
  ### Bootstrapping
  #######################
  
  # Initialize matrix to track SVD vectors (v) across synthetic (bootstrapped) samples
  syn_vecs = matrix(0,n_perms,dim(X_emp)[2])
  
  for(perm in 1:n_perms){
    
    # Shuffle rows of X, define as X_syn
    resamp_idx = sample(1:length(y), replace = T)
    X_syn = X_emp[resamp_idx,]
    
    # Match rows of y with rows of X
    y_syn = y[resamp_idx]
    
    # Z-score synthetic X
    X_syn = apply(X_syn,2,z_score)
    
    # Calculate the SVD of X_syn
    svd_syn =  svd(cor(y_syn,X_syn))
    
    # Deal with sign flips from SVD (if the dot product between +v and +v is less than -v and +v, flip v).
    if((t(svd_emp$v) %*% -svd_syn$v) > (t(svd_emp$v) %*% svd_syn$v)){
      svd_syn$v = -svd_syn$v
    }
    
    # Track the weight vectors of X_syn
    syn_vecs[perm,] = t(svd_syn$v)
  }
  
  # Calculate mean and standard deviation (bootstrapped standard error) of loadings across synthetic samples.
  vec_mean = apply(syn_vecs,2,mean)
  vec_sd = apply(syn_vecs,2,sd)
  
  # Calculate bootstrap ratio
  results$bs_ratio = as.data.frame(svd_emp$v/vec_sd)
  
  # Calculate LV scores
  results$lv_scores = X_emp %*% svd_emp$v
  
  # Calculate total variance in X accounted for by LV
  results$X_tot_var = sum(cor(results$lv_scores,X_emp)^2)/dim(X_emp)[2]
  
  # Calculate total variance in y accounted for by LV
  results$y_tot_var = cor(results$lv_scores,y)^2
  
  
  #######################
  ### Plotting 
  #######################
  
  # Plot permutation test
  max_val = max(syn_vars,sv_emp)
  max_val = max_val + max_val*.20
  
  png(paste(path,'permutation_test.png', sep = ''),width = 600, height = 400)
  hist(syn_vars,25, xlab = 'Singular Values', main = 'Permutation Distribution', xlim = c(0,max_val))
  abline(v = quantile(syn_vars,.95), col = 'black', lwd = 4, lty = 'dashed')
  abline(v = sv_emp, lwd = 4, col = 'red')
  legend('topright',c('Synthetic','95th percetile','Empirical'), lwd = 3, col = c('grey','black','red'))
  dev.off()
  
  # Plot bootstrap ratio
  rownames(results$bs_ratio) = names
  colnames(results$bs_ratio) = 'BS Ratio'
  min_val = min(0,t(results$bs_ratio))
  max_val = max(0,t(results$bs_ratio))
  
  png(paste(path,'bootstrap_ratio.png', sep = ''),width = dim(X)[2]*85, height = 400)
  barplot(t(results$bs_ratio), col = 'gray', ylab = 'Bootstrap Ratio',main = 'LV Boostrap Ratio', ylim = c(min_val,max_val))
  abline(h = 2.58, lwd = 2, lty = 'dashed')
  abline(h = -2.58, lwd = 2, lty = 'dashed')
  dev.off()
  
  # Plot LV weights w/ error bars
  rownames(svd_emp$v) = names
  colnames(svd_emp$v) = 'LV Weights'
  min_val = min(0,min(t(svd_emp$v) - vec_sd))
  max_val = max(0,max(t(svd_emp$v) + vec_sd))
  
  png(paste(path,'lv_weight.png', sep = ''), width = dim(X)[2]*85, height = 400)
  bar_plot = barplot(t(svd_emp$v), ylim = c(min_val,max_val), ylab = 'Weights', main = 'Latent Variable Weights', col = 'gray')
  arrows(x0 = bar_plot, y0 = t(svd_emp$v) + vec_sd, y1 = t(svd_emp$v) - vec_sd, angle = 90, code = 3, length = 0.15)
  dev.off()
  return(results)
}
