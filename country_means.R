# example R script to be invoked from the command line, it just finds the mean
# GDP for each country in an example file and makes a plot of population.

# commandArgs is nice for parsing command line arguments
# usage: Rscript yourScript.R arg1 arg2 arg3 ...
# Rscript will print anything sent to the R console
args <- commandArgs(trailingOnly = TRUE)
fileToOpen <- args[1]

# Got this crazy command from stackoverflow. It removes the file extension.
continent <- sub("\\.[[:alnum:]]+$", "", fileToOpen)
# paste is nice for mashing strings together
print(paste("Rscript running for ", continent, sep = ""))

file <- read.delim(fileToOpen, sep = "\t")

homePath <- getwd()
library(ggplot2)

for (nation in unique(file$country)) {
  dir.create(nation)
  setwd(nation)  
  sub <- subset(file, country == nation)
  
  # Let's make a file with the mean population.
  sink(file = paste(nation,".results"), sep = "")
  print(paste(nation,"'s mean population during the surveyed years was: ",
        mean(sub$pop)/1000000, " million.", sep = ""))
  print("Isn't that just wonderful.")
  sink(file = NULL)
  
  # Now let's make a file with a graph of the GDP.
  ggplot(sub, aes(x = year, y = gdpPercap)) + geom_point(size = 3) + geom_smooth(method = "loess") + theme_bw()
  ggsave(filename = paste(nation,".png", sep = ""), width = 10, height = 10, units = "cm", dpi = 150)
  
  setwd(homePath)
}

sink(file = paste(continent,".countries", sep = ""))

# gets rid of the stupid line #s in sink()
writeLines(sprintf("Countries analyzed:"))
writeLines(sprintf(as.character(unique(file$country)), "\n"))

sink(file = NULL)
