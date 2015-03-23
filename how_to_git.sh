#!/bin/bash

# List of git commands that are useful

# Setup
git config --global user.name "YOUR NAME"
git config --global user.email "YOUR EMAIL ADDRESS"

# initialize repository
git init

# clone repository (i.e. download)
git clone repoLink.git

# link your repository to a remote
git remote add remoteName remoteURL
# example
git remote add origin https://github.com/octocat/Spoon-Knife

# see git status
git status

# get diff
git diff fileName

# stage file for commit
git add fileName
# add everything in current directory
git add .

# unstage file for commit
git reset HEAD fileName

# commit added files
git commit -m 'Add a message here that describes the commit.'

# push to remote repository
git push remoteName branchName
# most common command
git push origin master

# sync your computer's stuff to remote repository
git pull

# create a new branch from current commit
git branch branchName

# checkout a different branch (or previous commit)
git checkout branchName
# checkout a different branch for a single file
git checkout branchName fileName

# merge two branches... merges branchName with current branch
git merge branchName
# if there is a conflict (i.e. each branch modified the same point of a file) you have to go in and fix the conflict yourself
# To view the conflict
git status
