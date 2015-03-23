#!/bin/bash

# This an example of why you may want to use a shell script to string together several parts of analysis.

# for grex
# module load r/3.1.0

# The first parameter passed after the name of your script is $1, the next is $2, and so on...
echo "Analyzing data from all the countries in $1."

export START=$(pwd)

# This removes the filename
export RUN_NAME=${1%%.*}.results
mkdir $RUN_NAME
cp $1 $RUN_NAME
cd $RUN_NAME

# iterate through every unique CONTINENT in $1
export LIST=$(tail -n +2 $1 | awk -F "\t" '{print $4}' | sort | uniq)
for CONTINENT in $LIST
	do
	echo "Now analyzing $CONTINENT"
	mkdir $CONTINENT

	# this is just to simulate data generation upstream, just pulling data out by CONTINENT
	# in reality, you would run upstream analysis in batch mode here, and then run R ont the subsequent data
	head -n 1 $1 > $CONTINENT.dat	
	grep $CONTINENT $1 >> $CONTINENT.dat
	mv $CONTINENT.dat $CONTINENT	
	cd $CONTINENT	

	# okay let's do a brief analysis in R
	Rscript $START/country_means.R $CONTINENT.dat

	cd $START/$RUN_NAME
done
	
echo "All done!"


