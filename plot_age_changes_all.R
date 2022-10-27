#############################################################################################
# Plot age-related changes in subfield volumes (all subfields on same plot, non-linear fits).
#############################################################################################

# Specify path with cleaned data.
path = 'C:\\Users\\jonah\\Documents\\MAGeT\\data\\'

# Load in ggplot and viridis (for colours).
library(ggplot2)
library(viridis)

# Load in data.
rh_data = read.csv(paste(path,'rh_data_cleaned.csv', sep = ''))
lh_data = read.csv(paste(path,'lh_data_cleaned.csv', sep = ''))

# Plot.

all_data = list(rh_data,lh_data)
plot_titles = c('Right Hemisphere', 'Left Hemisphere')
save_names = c('rh_all_subfields.png','lh_all_subfields.png')

cols = viridis(5)
span = 1.2

for(hem in 1:2){
  # Specify right/left hemisphere.
  data = all_data[[hem]]
  
  # Plot.
  ggplot(data = data) + 
    geom_point(aes(x = Age, y = CA1), col = cols[1]) +
    geom_point(aes(x = Age, y = Subiculum), col = cols[2]) +
    geom_point(aes(x = Age, y = CA4.DG), col = cols[3]) +
    geom_point(aes(x = Age, y = CA3.CA2), col = cols[4]) +
    geom_point(aes(x = Age, y = SRLM), col = cols[5]) +
    geom_smooth(method = 'loess', aes(x = Age, y = CA1), span = span, formula = data$CA1 ~ x, size = 1.5, col = cols[1], se = T)  +
    geom_smooth(method = 'loess', aes(x = Age, y = Subiculum), span = span, formula = data$Subiculum ~ x, size = 1.5, col = cols[2], se = T)  +
    geom_smooth(method = 'loess', aes(x = Age, y = CA4.DG), span = span, formula = data$CA4.DG ~ x, size = 1.5, col = cols[3], se = T)  +
    geom_smooth(method = 'loess', aes(x = Age, y = CA3.CA2), span = span, formula = data$CA3.CA2 ~ x, size = 1.5, col = cols[4], se = T)  +
    geom_smooth(method = 'loess', aes(x = Age, y = SRLM), span = span, formula = data$SRLM ~ x, size = 1.5, col = cols[5], se = T)  +
    ylim(c(0,1100)) +
    ylab(bquote('mm'^3)) +
    ggtitle('Left Hemisphere') +
    theme_classic() + 
    theme(plot.title = element_text(hjust = 0.5))
  
    
  # Save plot to path as .png.
  ggsave(paste(path,save_names[hem], sep = ''), plot = last_plot(),
         width = 6, height = 8)
}

