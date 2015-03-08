# biomaRt is a data mining tool that allows you extract massive amounts of data
# from online databases with minimal effort.

# This tutorial will use biomaRt to find the average distance between 
# transcription factor binding sites and the genes they are known to act on in 
# Drosophila (let's say we want to know how large an area we need to search 
# up/down from a gene while looking for new binding sites). Interestingly, I
# don't think there's actually a published value for this, so we're doing
# something new here.

# Jeff Stafford

# Load our starting dataset.
known_enhancers <- read.delim(file= "oreganno_dmel_full.txt", as.is = TRUE)

# This file was generated from oreganno_FULL_08Nov10.txt.gz, retrieved from 
# http://www.oreganno.org/oregano/Dump.jsp. Oreganno is a free and open
# regulatory element database. This is literally all of the Drosophila-related
# information in the database.
str(known_enhancers)

# Bash commands used to extract the Drosophila genes and generate the above file:
# gunzip oreganno_FULL_08Nov10.txt.gz
# grep -i 'drosophila melanogaster' > oreganno_dmel_data.txt 
# head -n 1 oreganno_FULL_08Nov10.txt > oreganno_dmel_full.txt
# cat oreganno_dmel_data.txt >> oreganno_dmel_full.txt 

# We are going to try to calculate the average distance between transcription
# factors and their targets. To do this, we need the start and end positions of
# each target.

# Our database already has the enhancer locations and targets.
head(cbind(known_enhancers$Gene.name, known_enhancers$chromStart))

# Now, let's try and retrieve all the information that would normally be in a
# .bed file for each gene (the gene start and end). 

library(biomaRt)

# We can browse a list of "marts" to use, generally each one is maintained by a
# separate organization. We're going to use ensembl, as it generally has the
# most variety in terms of species.
martList <- listMarts() 
head(martList)
ensembl <- useMart("ensembl")

# Which datasets do we want to use?
datasets <- listDatasets(ensembl)
head(datasets)
ensembl <- useMart("ensembl", dataset = "dmelanogaster_gene_ensembl")
# As an important side note, the Oreganno data and ensembl mart are both using 
# the BDGP5 annotation (the current annotation is BDGP6). A lot of things
# changed between these two versions, so using mismatched annotations would be BAD.

# What data do we want to retrieve?
attributes <- listAttributes(ensembl)
head(attributes)

# In this case, we want to grab several different versions of each gene name,
# chromosome each gene is on, and the start and end positions for each.
bedmap <- getBM(attributes = c("ensembl_gene_id", # FBgn number - changes often, but is highly specific
                               "flybasename_gene", # Actual gene names
                               "flybasecgid_gene", # CG number - similar to FBgn, but not all datasets have this.
                               "chromosome_name",
                               "start_position",
                               "end_position"),
                filters = "flybasename_gene", # "filters" is the category of values we are searching by
                values = known_enhancers$Gene.name, # "values" are the actual values we are searching with
                mart = ensembl) # Need to specify the mart/dataset we are searching.

# If something goes wrong, or if Ensembl ever updates its mart to BDGP6, we can
# also load the data this way:
# bedmap <- read.csv("TFbedmap.csv", as.is = TRUE)

# Check to make sure we got an annotation for every gene known to be associated
# with a transcription factor.
length(unique(known_enhancers$Gene.ID)) == length(unique(bedmap$flybasename_gene))

# Upon closer inspection of our TF dataset, much of the mismatch is due to the
# fact that not all of our binding sites are actually binding sites. The dataset
# includes regulatory regions not associated with any gene.
unique(known_enhancers$Type)
sub <- subset(known_enhancers, known_enhancers$Type == "TRANSCRIPTION FACTOR BINDING SITE")
sum(is.na(match(bedmap$flybasecgid_gene, sub$Gene.ID)))/length(sub$Gene.ID)
# All in all, it looks like we are missing about gene start/end information for 
# 11 percent of our genes. This is likely due to an annotation mismatch that I
# don't particularly feel like troubleshooting at the moment.

# Match up and annotate our enhancer db with what we know about their target genes.
tf_idx <- match(known_enhancers$Gene.ID, bedmap$flybasecgid_gene)

# With this index, we can simply add in our new data from ensembl.
known_enhancers$gene_start <- bedmap$start_position[tf_idx]
known_enhancers$gene_end <- bedmap$end_position[tf_idx]

# Okay so now we know where all of the genes in our TF database start. Lets
# calculate distances.
removeNegative <- function(bp) {
  if (is.na(bp)) {
    NA
  }
  else if (bp<0) {
    NA
  } else {
    bp
  }
}

known_enhancers$dist_from_start <- known_enhancers$chromStart - known_enhancers$gene_start
known_enhancers$dist_from_start <- apply(as.matrix(known_enhancers$dist_from_start),1,removeNegative)
known_enhancers$dist_from_end <- known_enhancers$chromStart - known_enhancers$gene_end
known_enhancers$dist_from_end <- apply(as.matrix(known_enhancers$dist_from_end),1,removeNegative)

mean(known_enhancers$dist_from_start, na.rm = TRUE)
mean(known_enhancers$dist_from_end, na.rm = TRUE)

range(known_enhancers$dist_from_start, na.rm = TRUE)
range(known_enhancers$dist_from_end, na.rm = TRUE)

# That's huge, but it looks like there two TFs with absurdly distant enhancers... 
# I'm going to arbitrarily exclude outliers over 50kb as a result (the stuff
# we'd probably want to do for downstream analysis won't even go that far
# anyways).

start_subset <- subset(known_enhancers, known_enhancers$dist_from_start < 50000)
hist(start_subset$dist_from_start, breaks = seq(0,50000,1000))
end_subset <- subset(known_enhancers, known_enhancers$dist_from_end < 50000)
hist(end_subset$dist_from_end, breaks = seq(0,50000,1000))

start_mean <- mean(start_subset$dist_from_start, na.rm = TRUE)
start_sd <- sd(start_subset$dist_from_start, na.rm = TRUE)

end_mean <- mean(end_subset$dist_from_end, na.rm = TRUE)
end_sd <- sd(end_subset$dist_from_end, na.rm = TRUE)

start_mean + start_sd
end_mean + end_sd
# It looks like enhancers are generally within 26.5kb of genes in Drosophila. 

length(start_subset$dist_from_start)/length(end_subset$dist_from_end)
# There are twice as many known enhancers upstream of genes compared to downstream.

# Again, these are very rough estimates and should be taken with a MASSIVE grain
# of salt (this is absurdly biased towards genes/enhancers that have been
# studied more). But hey, we answered our initial question and learned to use
# biomaRt, right?

