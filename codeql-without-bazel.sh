#!/bin/bash

#Certify that your runner has unzip 
#sudo apt install unzip

# Download CodeQL for Linux with cURL
wget https://github.com/github/codeql-cli-binaries/releases/download/v2.20.1/codeql-linux64.zip
mkdir $HOME/codeql-home
unzip codeql-linux64.zip -d $HOME/codeql-home

# Download queries and add them to the CodeQL home folder
git clone --recursive https://github.com/github/codeql.git $HOME/codeql-home/codeql-repo

# Check the configuration
$HOME/codeql-home/codeql/codeql resolve languages
$HOME/codeql-home/codeql/codeql resolve packs

# Build and create CodeQL database
$HOME/codeql-home/codeql/codeql database create codeqldb --language=python --threads=4 

export CODEQL_SUITES_PATH=$HOME/codeql-home/codeql-repo/python/ql/src/codeql-suites
mkdir $HOME/codeql-result

# # Code Scanning suite: Queries run by default in CodeQL code scanning on GitHub.
# # Default: python-code-scanning.qls
# # Security extended suite: python-security-extended.qls
# # Security and quality suite: python-security-and-quality.qls
$HOME/codeql-home/codeql/codeql database analyze codeqldb \
--format=sarif-latest \
--output=$HOME/codeql-result/python-code-scanning.sarif


# # Senf SARIF to GitHub
$HOME/codeql-home/codeql/codeql github upload-results \
--repository=$GITHUB_REPOSITORY \
--ref=$GITHUB_REF \
--commit=$GITHUB_SHA \
--sarif=$HOME/codeql-result/python-code-scanning.sarif \
--github-auth-stdin=$1

cat $HOME/codeql-result/python-code-scanning.sarif
