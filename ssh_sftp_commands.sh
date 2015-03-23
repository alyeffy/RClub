#!/bin/bash

# Login to another computer with ssh
ssh yourAccount@computer.network.ca

# With X windows enabled (i.e. connect to Westgrid)
# for linux
ssh -X yourAccount@computer.network.ca
# for macs
ssh -Y yourAccount@computer.network.ca

# You can generally use all the bash commands you would normally use.

# Westgrid specific commands:
# To sign up for Westgrid, you need to have your PI make a Compute Canada account, and then you make one under your PI's account.
# It's free!!!!

# Check out https://www.westgrid.ca//support/quickstart/new_users

# Show the whole queue
showq 

# Show your position in queue:
showq -u yourAccount

# Submit job... it likes .pbs files
# See https://www.westgrid.ca/files/PBS%20Script_0.pdf for formatting specifics!
qsub yourShellScript.pbs

# Delete a job
# Obtain job numbers with "showq -u yourname"
qdel jobNumber

# Leave account
exit

#####################################################

# Now lets cover sftp

# Connect
sftp yourAccount@computer.network.ca

# You can move around the connected computer with the same commands you would normally use:
cd
pwd
ls
# etc....

# To do the same on your computer, just add an 'l' in front of everthing....
lcd
lpwd
lls

# When you are ready to download a file
get fileName
# for getting multiple files- .txt for instance
mget *.txt

# To put a file from your computer 
put fileName
# multiple files - all of the files in a directory in this case
mput *

# Note: files always move between the remote directory (check with 'pwd') and your local directory (check with 'lpwd'). If moving something doesn't work, this is probably why!!!

# close sftp
bye


