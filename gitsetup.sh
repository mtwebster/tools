#!/bin/sh

# Automatic configuration for local Insoshi Git repository
#
# Requirements:
# 1. Working git installation
# 2. Fork of insoshi repository on GitHub
# 
# Usage:
# configure_insoshi_local [GitHub Account Name]
#
# This script will create a local clone of the official Insoshi Git
# repository located on GitHub.  The specified Insoshi fork will be
# added as an addtional remote repository and a new branch created to
# track local development.
#

# Verify number of arguments to script
#
MY_REMOTE="mtwebster"



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

# Create a local branch based off edge
#
echo "Creating local branch $NEW_BRANCH..."
git branch $NEW_BRANCH $UPSTREAM_BRANCH
catch_error $? "creating local branch $NEW_BRANCH"

git checkout $NEW_BRANCH
catch_error $? "checking out local branch $NEW_BRANCH"

echo

# Add forked repository as a remote repository connection
#
# The GitHub account name will be used to refer to this repository
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
