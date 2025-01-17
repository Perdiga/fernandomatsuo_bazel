#!/bin/bash

#Certify that your runner has unzip 
#sudo apt install unzip

# Install github linguist to extract repository languages
gem install github-linguist

# Download CodeQL for Linux with cURL
wget https://github.com/github/codeql-cli-binaries/releases/download/v2.20.1/codeql-linux64.zip
mkdir $HOME/codeql-home
unzip codeql-linux64.zip -d $HOME/codeql-home

# Download queries and add them to the CodeQL home folder
git clone --recursive https://github.com/github/codeql.git $HOME/codeql-home/codeql-repo

# Check the configuration
$HOME/codeql-home/codeql/codeql resolve languages
$HOME/codeql-home/codeql/codeql resolve packs

cd $HOME/codeql-home/codeql-repo
github-linguist

# Build and create CodeQL database
$HOME/codeql-home/codeql/codeql database create codeqldb --db-cluster --language=python,javascrit --threads=4 

# # Code Scanning suite: Queries run by default in CodeQL code scanning on GitHub.
# # Default: python-code-scanning.qls
# # Security extended suite: python-security-extended.qls
# # Security and quality suite: python-security-and-quality.qls
mkdir $HOME/codeql-result
$HOME/codeql-home/codeql/codeql database analyze codeqldb \
--format=sarif-latest \
--output=$HOME/codeql-result/code-scanning.sarif

# # Senf SARIF to GitHub
$HOME/codeql-home/codeql/codeql github upload-results \
--repository=$GITHUB_REPOSITORY \
--ref=$GITHUB_REF \
--commit=$GITHUB_SHA \
--sarif=$HOME/codeql-result/code-scanning.sarif \
--github-auth-stdin=$1

cat $HOME/codeql-result/code-scanning.sarif
