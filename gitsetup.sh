#!/bin/sh

# Github configuration of individual repositories for Android development
#
# Download this and run: 
#
# chmod a+x gitsetup
#
# to make it executable
#
# Requirements:
# 1. Repo tool-based initial setup
# 2. Fork of desired repository (i.e. frameworks_base, phone, etc..)
# 3. Configured git installation
# 4. Be in top-level folder of the repository you want to configure (i.e. for Phone app, ~/<my_project>/packages/apps/Phone)
# 
# Usage:
# gitsetup [tracking branch] [new branch] [git@ address for your fork]
#
# This script will setup your git config (for a particular individual repository)
# to simplify modifying code and pushing it to your personal fork of that repository
# It will:
# 
# Setup to track changes to [tracking branch]
# Create a new branch named [new branch] based off the tracking branch
# Check out that new branch
# Push an initial commit to your github to create that branch, at the specified git@ address
# Set up an alias for interacting with that fork, defined by MY_REMOTE below
#
# The resulting configuration will allow you to perform such things as:
#
# - Allow you to repo sync your entire project (without having to worry about how your individual changes will be affected.
# - Pull and push from your Github simply by entering git push <my_remote> <branch>
#
#  Common things I do once I've set up the git config on a particular repository I'm working on:
#
# - (following a git commit) git push <myremote> <mybranch> ............ Pushes latest commit(s) to Github
#
# - git pull --rebase github <tracking branch>.....Re-sync my local copy of the tracking branch, then apply my commits
#   to the end (this keeps the commit history clean, so when it's time to do a pull request, there aren't a bunch m
#   merges clouding things up.  This is what the repo tool runs on each repository when you do 'repo sync.'  By the way,
#   the 'github' in that command is the name the repo tool assigns to the "upstream" address of "git://github.com/"
#
# - (following a git commit) git push --force <myremote> <mybranch>..... resets my Github branch with my local branch, 
#   FORCING the local history - basically overwrites the Github copy with my local copy.  WARNING - you will lose any 
#   history on your Github that isn't also in your local branch.  This is generally considered bad form, but I do it 
#   before issuing a Pull Request, as I tend to use Github as a "backup" tool, and when I'm all done with stuff, I'd 
#   rather have all my changes in a single commit.
#
# 
# 
# Enter a simple name to make pushing/pulling easier.  This will NOT be seen publicly.
# It simply replaces having to enter git@github.com:<you>/<yourfork> every time you want to interact
# with your fork.  Instead you can just enter 'git push mygit <myfork>' and so on.
#
MY_REMOTE="mygit"
#
#
#
#
if [ $# -ne "3" ]
then
  echo "Usage: gitsetup [tracking branch] [new branch] [git@ address for your repository]"
  exit 1
fi

GITHUB_ACCOUNT=`echo $3`

REMOTE=`echo $GITHUB_ACCOUNT`

NEW_BRANCH=`echo $2`
UPSTREAM_BRANCH=`echo $1`
# Error handling function
catch_error() {
  if [ $1 -ne "0" ]
  then
    echo "ERROR encountered $2"
    exit 1
  fi
}

echo

# Create a local branch that tracks the forked master branch
#
echo "Creating local tracking branch for ..."
git branch --track $UPSTREAM_BRANCH github/$UPSTREAM_BRANCH
catch_error $? "creating local tracking branch for $UPSTREAM_BRANCH"

# Create a local branch based off upstream
#
echo "Creating local branch $NEW_BRANCH..."
git branch $NEW_BRANCH $UPSTREAM_BRANCH
catch_error $? "creating local branch $NEW_BRANCH"

git checkout $NEW_BRANCH
catch_error $? "checking out local branch $NEW_BRANCH"

echo

# Add forked repository as a remote repository connection
#
# 
#
echo "Adding remote connection to forked repository..."
git remote add $MY_REMOTE $GITHUB_ACCOUNT
catch_error $? "adding remote $MY_REMOTE"

echo

# Fetch branch information
#
echo "Fetching remote branch information..."
git fetch $MY_REMOTE
catch_error $? "fetching branches from remote $MY_REMOTE"

echo

# Create the matching remote branch on the forked repository
#
# We need to explicitly create the branch via a push command
#
echo "Pushing local branch $NEW_BRANCH to remote $MY_REMOTE..."
git push $MY_REMOTE $NEW_BRANCH:refs/heads/$NEW_BRANCH
catch_error $? "pushing local branch $NEW_BRANCH to remote $MY_REMOTE"

echo

# Configure the remote connection for the local branch
#
echo "Configuring remote connection for local branch $NEW_BRANCH..."

git config branch.$NEW_BRANCH.remote $MY_REMOTE
catch_error $? "configuring remote $MY_REMOTE for local branch $NEW_BRANCH"

git config branch.$NEW_BRANCH.merge refs/heads/$NEW_BRANCH
catch_error $? "configuring merge tracking for local branch $NEW_BRANCH"

exit 0