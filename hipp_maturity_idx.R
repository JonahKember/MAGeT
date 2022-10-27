#############################
# Hippocampus maturity index
#############################

# Specify whether hippocampal volume should be controlled for.
vol_ctrl = T

# Specify whether the hippocampal maturity index (1st PLS component) should be calculated using all subjects, or only those with Pic-Seq scores.
inclusion = T

# Path with cleaned data output from clean_data.R
path = 'C:\\Users\\jonah\\Documents\\MAGeT\\data\\'

# Load in data.
rh_data = read.csv(paste(path,'rh_data_cleaned.csv', sep = ''))
lh_data = read.csv(paste(path,'lh_data_cleaned.csv', sep = ''))

# Load in necessary libraries.
library(pls)
library(ggplot2)

# Specify hemisphere
data = lh_data

if(vol_ctrl == T){
  tot_vol = apply(data[,3:7],1,sum)
  data[,3:7] = data[,3:7]/tot_vol
}

if(inclusion == T){
  include = which(data$Picture.Seq..Scores > 0)
  data = data[include,]
}

# Find PLS components (directions that maximize covariance between volume matrix and age).
pls_fit = plsr(Age ~ CA1 + Subiculum + CA4.DG + CA3.CA2 + SRLM, data = data, scale = T)

# Plot relationship between the 1st PLS component and Picture-Sequence scores..
ggplot(data = data, aes(x = pls_fit$scores[,1], y = Picture.Seq..Scores)) + 
  geom_point() +
  theme_classic() +
  xlab('Hippocampal Maturity Index (z-score)') +
  ylab('Picture Sequence Scores') +
  ylim(c(75,140)) +
  geom_smooth(method = 'lm', formula = y ~ x, size = 1.5, col = 'black', fullrange = T)

# Save plot to path as .png.
ggsave(paste(path,'hipp_maturity_pic_seq.png', sep = ''), plot = last_plot(), width = 8, height = 5)

# Calculate total variance explained.
pls_loadings =  pls_fit$loadings[,1]
X_var = pls_fit$Xvar/pls_fit$Xtotvar[1]
Y_var = cor(pls_fit$scores,data$Age)[1]^2

# Calculate correlation between hippocampal maturity and memory.
cor_results = cor.test(data$Picture.Seq..Scores, pls_fit$scores[,1])

# Display relevant results.
cat('Total variance in X:',X_var[1]*100,'%. \nTotal variance in Y:',Y_var*100,'%.')
cat('Correlation between hippocampal maturity and picture-sequence scores: r =',cor_results$estimate,'p =',cor_results$p.value)
cat('PLS loadings:',pls_fit$loadings[,1])
