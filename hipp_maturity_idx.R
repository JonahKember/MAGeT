#############################
# Hippocampus maturity index
#############################

# Path with cleaned data from clean_data.R
path = 'C:\\Users\\jonah\\Documents\\MAGeT\\data\\'

# Load in data.
rh_data = read.csv(paste(path,'rh_data_cleaned.csv', sep = ''))
lh_data = read.csv(paste(path,'lh_data_cleaned.csv', sep = ''))

# Load in necessary libraries.
library(pls)
library(ppcor)
library(ggplot2)

# Specify data.
data = lh_data

# Find PLS components (direction that maximizes covariance between volume matrix and age).
pls_fit = plsr(Age ~ CA1 + Subiculum + CA4.DG + CA3.CA2 + SRLM, data = data, scale = T)
summary(pls_fit)

# Test the correlation between each component and picture sequence scores.
for (var in 1:5){
  print(cor.test(data$Picture.Seq..Scores, pls_fit$scores[,var]))
}

# Plot the correlation between the 1st PLS component and Picture-Sequence scores.
ggplot(data = data, aes(x = pls_fit$scores[,1], y = Picture.Seq..Scores)) + 
  geom_point() +
  theme_classic() +
  xlab('Hippocampus Maturity Index (z-score)') +
  ylab('Picture Sequence Scores') +
  ylim(c(75,140)) +
  geom_smooth(method = 'lm', formula = y ~ x, size = 1.5, col = 'black', fullrange = T)

# Save plot to path as .png.
ggsave(paste(path,'lh_hipp_maturity_pic_seq.png', sep = ''), plot = last_plot(),
       width = 8, height = 5)


