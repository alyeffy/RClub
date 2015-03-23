#!/bin/bash

# The command line/console is what actually does things on your computer. Many programs and application launchers are actually very small shell scripts comprised of just the command to run other parts of the program. 

# This is a tutorial for bash (Bourne Again SHell), which is the most commonly used shell. There are others (like the Windows command line), but I can almost guarantee that you will never ever use them. Bash is the default terminal for almost all UNIX computers (all Apple products/Android/Linux devices). 

# So what does it do? Long story short, it's a programming language for your OS. You can use it to manage files, run programs, and edit/process files. Many computationally-heavy programs do not have a user interface and must be run from the command line. 

# But let's start from the absolute beginning. Open up bash (it's usually called 'Terminal' or something like that)

# So what do we see when we open it?
# jeff@jeff-superduperultra:~$ 

# jeff (before the '@') = is my current username.
# jeff-superduperultra = is the name of the computer I am on (cheesy name, I know...).
# ~ = my current location. '~' is a special case, and indicates that we are in my home directory: /home/jeff

# We can also obtain our current location with pwd (print working directory)
pwd

# What is in our working directory? 
ls

# How do we change directories? Use the cd (change directory) command. Let's go to my Documents folder.
cd Documents
# Windows people need to do this first: mkdir Documents
pwd
ls
# Notice how the prompt now displays ~/Documents for our location.

# cd can be used to go to any folder on your computer. To go somewhere, type the full length of the file directory (or use shortcuts).

# To go back to h~/Documentsome - both of these commands work
cd ~ # remember ~ = /home/yourUserName

# There are also two shortcuts you can use for getting around faster on the command line. 
# . = current directory name
# .. = last directory name
# You can also use the tab key to autocomplete things as you type. Partially type something out, press tab, and it will either autocomplete or show you a list of the possiblities.

cd ./Documents # current directory/Documents
pwd
cd .. # go back to parent directory
pwd

# Many commands also have multiple behaviors that you can invoke with command line 'flags.' What is a flag? It's generally just your command followed by a '-' and the name of the flag (sometimes it's '--' followed by the name of the flag. You follow the flag with any additional arguments you might need.

# Let's go back to 'ls'
ls -a # shows hidden files. 'Hidden' files are those that begin with a '.' like '.bashrc'
ls -l # show files, their size in bytes, date last modified, permissions, etc. We'll come back and explain permissions later.

# Now that we know a little bit, here are several really huge tips.
# '#' is the character that comments out a line
# Ctrl-C DOES NOT copy. Ctrl-C breaks execution of whatever is currently happening.
# Ctrl-Shift-C copies whatever is highlighted with the mouse (you can also right-click -> copy)
# Ctrl-Shift-V pastes what is on the clipboard.
# If you ever want help with a command, type 'man commandName'
# Also: everything is CASE-SENSITIVE (you need to use proper capitalization)
man ls

# 'echo' just repeats whatever you just typed. You can also use it to see what different shell variables are.
echo 'this is a test'
echo ~ 
# like I said earlier ~ = /home/yourUserName

# Let's create a text file. '>' redirects the output of any command to a text file.
echo 'this is a test' > test.txt
ls
ls > test2.txt # redirects the output from ls into text2.txt

# Let's look at our files.
# 'cat' reads out the entire file
cat test.txt
# cat can also read multiple files in the order you specify
cat test2.txt test.txt
cat test2.txt test.txt > combined_file.txt
cat combined_file.txt

# Often you don't want to read out the entire file.
# 'more' displays things one thing at a time (press enter to view more), output stays in front of you when done. Press 'q' to get rid of it
more test2.txt 
# 'less' is the same as 'more', but disappears when you press 'q'
less test2.txt 
# you can also just look at the first 5 lines with 'head' (you can specify more or less lines with -n
head test2.txt
head -n 1 test2.txt
# tail is same as head but for end of file
tail test2.txt

# Lets make a new directory with mkdir
mkdir newDirectory
ls

# Let's move a file there
mv combined_file.txt newDirectory
ls newDirectory 
# our file is there!

# We can also do things to multiple files at once with the wildcard character (*). Everything that matches the pattern specified by the wildcard will be targeted by a command.
mv test* newDirectory #moves everything with 'test' in the filename
cd newDirectory
ls

# Lets rename one of them. 
# mv <filename> <newFilename>
mv combined_file.txt newName.extension

# Let's delete a file. BE VERY CAREFUL WITH THIS. FILES THAT YOU DELETE ARE GONE FOREVER!!!!!! There is no recycle bin for this.
rm test2.txt
ls

# delete all .txt files
rm *.txt
ls

# cp copies files
cp newName.extension newName2.lalala #copy file into current directory
cp newName.extension .. #copy file into another directory, in this case .. (parent directory)
ls

# Let's delete all the files in this directory
rm *
cd ..

# Remove that directory we made. The directory needs to be empty or this will not work. 
rmdir newDirectory

# Okay those are the basics. Let's take it up a notch and actually do something. This is where things get (slightly) awesome.

mkdir bash_tutorial
cd bash_tutorial

# 'wget' downloads a file from a specified web address
wget ftp://ftp.ensembl.org/pub/release-77/gtf/drosophila_melanogaster/Drosophila_melanogaster.BDGP5.77.gtf.gz

# gunzip unzips .gz files
# unzip unzips .zip files
# unrar unzips .rar files
# tar -zxvf unzips .tar.gz files
# tar -xjf unzips .tar.bz2 files
gunzip Drosophila_melanogaster.BDGP5.77.gtf.gz

head Drosophila_melanogaster.BDGP5.77.gtf
# This is a GTF2 file. GTF files describe genetic features and landmarks in a particular genome. They can include any number of different feature types.
# To see what this one contains... 
awk -F "\t" '{ print $3 }' Drosophila_melanogaster.BDGP5.77.gtf | sort | uniq

# What just happened? How did that command even work?
# The '|' character is known as a pipe. It sends the output of one command to the next command in the chain. In this case the output from 'awk' (it's reading the third column of this dataset, which tells you what each feature is) is being sent to 'sort' (sorts everything alphabetically), which is then sent to 'uniq' (returns only the unique values. 

# Let's try that ourselves. What if we hypothetically wanted to know how many lines corresponded to Act5C (Actin)?

# grep is a pattern matching command. It will return however many lines match a particular pattern in a file. 
# Usage: grep <oattern> <file>
grep Act5C Drosophila_melanogaster.BDGP5.77.gtf 
# Those are all the lines that have Act5C in them. If we wanted to make a file with all of the Act5C related information, we could just do:
grep Act5C Drosophila_melanogaster.BDGP5.77.gtf > Act5C.gtf
head Act5C.gtf

# wc returns word counts. In this case we want the number of Act5C-related lines, so we will use wc -l
wc -l Act5C.gtf 

# What if we wanted the number of Act5C-related entries in one command? Let's 'pipe' the output of grep to wc -l
grep Act5C Drosophila_melanogaster.BDGP5.77.gtf | wc -l
# Looks like there are 37 lines.

# What if we wanted to make a GTF file that only contained genes and exons? Awk is a more powerful version of grep. See here for a detailed tutorial: http://reasoniamhere.com/2013/09/16/awk-gtf-how-to-analyze-a-transcriptome-like-a-pro-part-1/

awk -F "\t" '$3 == "gene" || $3 ==  "exon" { print }' Drosophila_melanogaster.BDGP5.77.gtf > transcriptome.gtf
# -F specifies what delimiter to use in this case \t = tab.
# Area inside the single quotes specifies what patterns to match and what to print. We specify what to print inside the {}. 

# Lets check our work:
awk -F "\t" '{ print $3 }' transcriptome.gtf | sort | uniq

# What if we wanted a (non-redundant) list of every gene name? We can actually chain awk calls together
awk -F "\t" '$3 == "gene" {print $9}' Drosophila_melanogaster.BDGP5.77.gtf | awk -F "\;" '{print $3}' > genes.txt
head genes.txt
# We first searched through the 3rd tab-delimited column for genes, and sent the 9th column (the actual details) to the next 'awk' command which printed the 3rd ';'-delimited column and sent it to a file called genes.txt

# What if we didn't want all of the 'gene name "..."' business?
# sed is a text replacer/editor that you can invoke from the command line. Here is the only command you need to know (substitution).
# Usage: sed -i 's/<words_to_replace>/<new_words>/g' <filename>
# The -i perfoms an 'in place' edit. Remove it, and output is sent to the console.
# sed -i 's/<replace words>/<replace with>/g' <files>
sed -i 's/gene_name\ \"//g' genes.txt
# We are replacing gene_name "*" with nothing in this case.
head genes.txt
# whoops missed the last " somehow
sed -i 's/\"//g' genes.txt
head genes.txt
# There we go!

# All of these commands we have been running are built into every UNIX distribution (macs/linux). What if we want to run commands/programs that are not specified by default?

# Let's grab the sequencing QC tool FastQC. It gives quality information for the raw fastq files that come off of a sequencer.
wget www.bioinformatics.babraham.ac.uk/projects/fastqc/fastqc_v0.11.2.zip
unzip fastqc_v0.11.2.zip
cd FastQC

# Remember how I mentioned permissions earlier? fastqc (the program we want to run) requires permission to run. You have to manually give it that permission before you can run any script/program.
ls -l # allows us to view permissions
# r = read (4) - allows us to read the file
# w = write (2) - allows us to edit the file
# x = execute (1) - allow us to run the file
# First column (of rwx) is for us (the user), second column is for other accounts on this computer, last is for anyone to do stuff

# To change permissions, we need to use 'chmod'. 
chmod +x fastqc 
#gives everyone permission to execute fastqc
# if it ever says "Permission Denied" add 'sudo' before a command and enter your password to become root (all-powerful). Be careful with sudo.
# you can also do "chmod 700 fastqc", which gives us permissions 4 (read), 2 (write), and 1 (execute), and others/world 0 (can't do anything)

# to run any script that isn't built-in to your OS, you need to specify the directory and THEN the name of the script.
# like this:
./fastqc
# woo, it works... now lets try running it on some data in batch mode

# Let's get our example data, in this two files containing the first 50000 pairs of reads from an Illumina HiSeq 
cd ..
wget http://download1511.mediafire.com/24marqhdb3ig/jj83sqhzwqa9gpz/fsugar_00_1_1.fastq.gz
wget http://download1079.mediafire.com/1daefe1h12jg/p1hwpej9b1iw9jk/fsugar_00_1_2.fastq.gz
gunzip *.gz # unzipping just to make the tutorial a little simpler (the tools we are going to use can actually interpret .gz files).

# These fastq files contain the first 50000 100bp paired-end RNA-SEQ reads (Illumina HiSeq 2000) from the brains of female sugar-fed A. aegypti mosuitoes. I got the data from here: http://www.ncbi.nlm.nih.gov/sra/SRX468715 
FastQC/fastqc fsugar_00_1_1.fastq
# open the resulting html file (fsugar_00_1_1_fastqc.html) in your browser by clicking on it
# As you can see, this is a very messy dataset. Read quality dramatically declines towards the end of most reads. It's not usually an option to re-sequence a dataset. So how can we fix it?

# Let's use seqtk, a very fast fastq processing algorithm.
wget https://github.com/lh3/seqtk/archive/master.zip
#on cygwin: wget --no-check-certificate https://github.com/lh3/seqtk/archive/master.zip
# If you have git installed, you can just use
# git clone https://github.com/lh3/seqtk.git
unzip master.zip
cd seqtk-master
ls
# As this is just source code, we need to compile it.
make
# Note: Macs don't actually ship with the ability to 'make' anything, which is simply outrageous. You need to install it by getting XCode and the Command Line Tools before you can 'make' things.
ls -l
# Yay, it's made and even has permission to execute.

# Let's use seqtk to trim and fix that bad fastq file.
cd ..
seqtk-master/seqtk trimfq fsugar_00_1_1.fastq > trim.fastq
FastQC/fastqc trim.fastq
# Now if you open the QC report, you'll notice that we've fixed the data. It's now ready for alignment.

# Let's try writing a small shell script to do this for both files at once.
# Get rid of the files that we just made
rm trim* *fastqc*


# Create a new file in your text editor of choice.

# THE FIRST LINE OF YOUR FILE MUST BE (it tells your OS to interpret this using bash):
#!/bin/bash

# Let's create a simple for loop in your shell:

# again remember that '#' comments things out and does not get run
for file in *.fastq 
# 'file' is a shell variable that iterates over all of the fastq files
# To access a shell variable, just add a '$' to the front of it
	do
	echo "Processing $file"
	seqtk-master/seqtk trimfq $file > $file.trim
	FastQC/fastqc $file.trim
done
echo "All done!"

# Here are some other tricks for extracting filenames minus their extensions (I stole this from here: http://stackoverflow.com/questions/965053/extract-filename-and-extension-in-bash)
# FILE="example.tar.gz"
# echo "${FILE%%.*}"
# example
# echo "${FILE%.*}"
# example.tar
# echo "${FILE#*.}"
# tar.gz
# echo "${FILE##*.}"
# gz

# Just like in R, a shell script is simply a file that contains a string of commands to run.

# now save the file as <filename>.sh (the .sh also tells your OS this is a shell script. I saved mine as "QC_tool.sh"
sudo chmod 700 QC_tool.sh
./QC_tool.sh
# cool, right?

# If we wanted it to be quieter and write what it did into a logfile:
./QC_tool.sh &> QC_run.log
# Note: when you are running stuff in the console, you see the output of BOTH std_out and std_err. '&>' redirects both of them, while '>' only redirects std_out

# Say you hypothetically want to run an R script on the console or as part of a shell script.
# Use this syntax:
# R CMD BATCH [options] my_script.R [outfile] 
