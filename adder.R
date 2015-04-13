# add two numbers together

# Rscript adder.R 4 5

# first  <- 4
# second <- 5

args <- commandArgs(trailingOnly = TRUE)
first <- as.numeric(args[1])
second <- as.numeric(args[2])

# print to console
first + second

writeLines(sprintf(as.character(first + second)))

# write it to a file 
filename  <- "results.txt"
sink(file = filename)
first + second
sink(file = NULL)