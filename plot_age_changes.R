########################################
# Age-related changes in subfield volume
########################################

path = 'C:\\Users\\jonah\\Documents\\MAGeT\\data\\'

# Load in data.
rh_data = read.csv(paste(path,'rh_data_cleaned.csv', sep = ''))
lh_data = read.csv(paste(path,'lh_data_cleaned.csv', sep = ''))

# Load in ggplot.
library(ggplot2)

# Specify subfields to be fit.
subfield = list(rh_data$CA1,rh_data$Subiculum,rh_data$CA4.DG,rh_data$CA3.CA2,rh_data$SRLM)
sf_titles = c('CA1','Subiculum','CA4/DG','CA3/CA2','SRLM')
sf_save_names = c('CA1','Subiculum','CA4,DG','CA3,CA2','SRLM')

# Non-linear fits
#################

# Loop through subfields plot result, save plot.
for (sf in 1:length(subfield)){

  # Plot volume as a function of age, overlay fit.
  ggplot(data = rh_data, aes(x = Age, y = subfield[[sf]])) + 
    geom_point() +
    ylab(bquote('mm'^3)) + 
    ggtitle(sf_titles[sf]) +
    theme_classic() + 
    theme(plot.title = element_text(hjust = 0.5)) +
    geom_smooth(method = 'loess', span = 1.5, formula = y ~ x, size = 1.5, col = 'black', se = T)
  
  # Save plot to path as .png.
  ggsave(paste(path,sf_save_names[sf],'_nonlinear.png', sep = ''), plot = last_plot(),
         width = 8, height = 5)
}


# Linear fits
#############

# Loop through subfields, fit lm, plot result, save plot.
for (sf in 1:length(subfield)){
  fit = smooth.spline(rh_data$Age,subfield[[sf]])
  
  # Plot volume as a function of age, overlay fit.
  ggplot(data = rh_data, aes(x = Age, y = subfield[[sf]])) + 
    geom_point() +
    ylab(bquote('mm'^3)) + 
    ggtitle(sf_titles[sf]) +
    theme_classic() + 
    theme(plot.title = element_text(hjust = 0.5)) +
    geom_smooth(method = 'lm', formula = y ~x, se = T, size = 1.5, col = 'black')
  
  # Save plot to path as .png.
  ggsave(paste(path,sf_save_names[sf],'_linear.png', sep = ''), plot = last_plot(),
         width = 8, height = 5)
}
