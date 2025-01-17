#!/bin/bash

#Certify that your runner has unzip 
#sudo apt update
#sudo apt install build-essential
#sudo apt install unzip

# You may need to use sudo to run the following steps depending on your runner configuration
wget https://github.com/bazelbuild/bazelisk/releases/download/v1.25.0/bazelisk-linux-amd64
#sudo chmod +x bazelisk-linux-amd64
sudo mv bazelisk-linux-amd64 /usr/local/bin/bazel
which bazel

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
sudo $HOME/codeql-home/codeql/codeql database create codeqldb --language=python \
--command='bazel build --spawn_strategy=local --nouse_action_cache --noremote_accept_cached --noremote_upload_local_results'

export CODEQL_SUITES_PATH=$HOME/codeql-home/codeql-repo/python/ql/src/codeql-suites
mkdir $HOME/codeql-result

# # Code Scanning suite: Queries run by default in CodeQL code scanning on GitHub.
# # Default: python-code-scanning.qls
# # Security extended suite: python-security-extended.qls
# # Security and quality suite: python-security-and-quality.qls
$HOME/codeql-home/codeql/codeql database analyze codeqldb \
--threads=4 \
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

bazel clean --expunge
bazel shutdown

