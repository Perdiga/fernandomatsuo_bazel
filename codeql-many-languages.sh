#!/bin/bash

#Certify that your runner has unzip 
#sudo apt update
#sudo apt install unzip

# Install github linguist to extract repository languages
sudo apt-get install build-essential cmake pkg-config libicu-dev zlib1g-dev libcurl4-openssl-dev libssl-dev ruby-dev
sudo gem install github-linguist

# Download CodeQL for Linux with cURL
wget -q https://github.com/github/codeql-cli-binaries/releases/download/v2.20.1/codeql-linux64.zip
mkdir $HOME/codeql-home
unzip codeql-linux64.zip -d $HOME/codeql-home

# Download queries and add them to the CodeQL home folder
#git clone --recursive https://github.com/github/codeql.git $HOME/codeql-home/codeql-repo

# Check the configuration
$HOME/codeql-home/codeql/codeql resolve languages
$HOME/codeql-home/codeql/codeql resolve packs

cd ls -l

cd $HOME/codeql-home/codeql-repo
github-linguist

# Define the languages CodeQL supports
declare -A language_map=(
    ["C++"]="cpp"
    ["C#"]="csharp"
    ["Go"]="Go"
    ["Java"]="Java"
    ["JavaScript"]="JavaScript"
    ["Python"]="Python"
    ["TypeScript"]="TypeScript"
    ["Ruby"]="Ruby"
    ["Swift"]="Swift"
    ["Kotlin"]="Kotlin"
)

# Get the detected languages from GitHub Linguist and extract the language column
detected_languages=$(github-linguist | awk '{print $3}')

# Filter the detected languages to include only those supported by CodeQL
filtered_languages=()
for lang in $detected_languages; do
    if [[ ${language_map[$lang]+_} ]]; then
        filtered_languages+=("${language_map[$lang]}")
    fi
done

echo "Languages detected by GitHub Linguist: $detected_languages"

# Output the filtered languages as a comma-separated string
codeql_supported_languages=$(echo "${filtered_languages[*]}" | tr ' ' ',' | tr '[:upper:]' '[:lower:]')

# Build and create CodeQL database
$HOME/codeql-home/codeql/codeql database create codeqldb \ 
--db-cluster \
--language=$codeql_supported_languages \
--threads=4 

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
