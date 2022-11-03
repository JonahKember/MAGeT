#################################
# Clean data for further analyses
#################################

path = 'C:\\Users\\jonah\\Documents\\MAGeT\\data\\'
  
# Load in data.
rh_data = read.csv(paste(path,'rh_volumes_demographics.csv',sep = ''))
lh_data = read.csv(paste(path,'lh_volumes_demographics.csv',sep = ''))

# Remove irrelevant data (raw scores, redundant age/income/ID variables).
rh_data = rh_data[,c(2:7,9:12,15,19,22,23:38)]
lh_data = lh_data[,c(2:7,9:12,15,19,22,23:38)]

# Rename columns.
colnames(rh_data) = c('ID','CA1','Subiculum','CA4/DG','CA3/CA2','SRLM',
                      'Age','Sex','Site','Income',
                      'IQ (MR)','Picture Seq. Scores','Picture Seq. Theta','ICV',
                      'MD-CA1',	'MD-Subiculum',	'MD-CA4/DG',	'MD-CA3/CA2',	'MD-SRLM',	'FA-CA1',	
                      'FA-Subiculum',	'FA-CA4/DG',	'FA-CA3/CA2',	'FA-SRLM',	'T1T2-CA1',	
                      'T1T2-Subiculum',	'T1T2-CA4/DG',	'T1T2-CA3/CA2',	'T1T2-SRLM')

colnames(lh_data) = c('ID','CA1','Subiculum','CA4/DG','CA3/CA2','SRLM',
                      'Age','Sex','Site','Income',
                      'IQ (MR)','Picture Seq. Scores','Picture Seq. Theta','ICV',
                      'MD-CA1',	'MD-Subiculum',	'MD-CA4/DG',	'MD-CA3/CA2',	'MD-SRLM',	'FA-CA1',	
                      'FA-Subiculum',	'FA-CA4/DG',	'FA-CA3/CA2',	'FA-SRLM',	'T1T2-CA1',	
                      'T1T2-Subiculum',	'T1T2-CA4/DG',	'T1T2-CA3/CA2',	'T1T2-SRLM')

# Transform to data-frames.
rh_data = as.data.frame(rh_data)
lh_data = as.data.frame(lh_data)

# Define factors within nominal variables.
data$Sex = as.factor(data$Sex)
levels(data$Sex) = c('Male','Female')

# Set missing scores to NA
rh_data$'Picture Seq. Scores'[rh_data$'Picture Seq. Scores' == 0] = NA
rh_data$'Picture Seq. Theta'[rh_data$'Picture Seq. Theta' == 0] = NA
rh_data$Income[rh_data$Income < 0] = NA
rh_data[rh_data$`MD-CA1` == 0,15:29] = NA

lh_data$'Picture Seq. Scores'[lh_data$'Picture Seq. Scores' == 0] = NA
lh_data$'Picture Seq. Theta'[lh_data$'Picture Seq. Theta' == 0] = NA
lh_data$Income[lh_data$Income < 0] = NA
lh_data[lh_data$`MD-CA1` == 0,15:29] = NA

# Visualize standardized data.
z_score <- function(x) {(x - mean(x, na.rm = T))/sd(x, na.rm = T)}
  
z_rh_data = apply(rh_data[,2:29],2,z_score)
z_lh_data = apply(lh_data[,2:29],2,z_score)

# Create box plots, exclude nominal vars (sex, site).
boxplot(z_rh_data[,c(-7,-8)], ylab = 'Z-Score')
title('Right Hemisphere')
boxplot(z_lh_data[,c(-7,-8)], ylab = 'Z-Score')
title('Left Hemisphere')

# Save cleaned data
write.csv(rh_data,paste(path,"rh_data_cleaned.csv",sep = ''))
write.csv(lh_data,paste(path,"lh_data_cleaned.csv",sep = ''))
