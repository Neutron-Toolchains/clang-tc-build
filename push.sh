#!/usr/bin/env bash

# Function to show an informational message
msg() {
    echo -e "\e[1;32m$*\e[0m"
}

# Set a directory
DIR="$(pwd ...)"

# Inlined function to post a message
BOT_MSG_URL="https://api.telegram.org/bot$TOKEN/sendMessage"
BOT_STICKER_URL="https://api.telegram.org/bot$TOKEN/sendSticker"
builder_commit="$(git rev-parse HEAD)"

# Build Info
rel_date="$(date "+%Y%m%d")" # ISO 8601 format
rel_friendly_date="$(date "+%B %-d, %Y")" # "Month day, year" format

# Release Info
pushd llvm-project || exit
llvm_commit="$(git rev-parse HEAD)"
short_llvm_commit="$(cut -c-8 <<< "$llvm_commit")"
popd || exit

llvm_commit_url="https://github.com/llvm/llvm-project/commit/$short_llvm_commit"
binutils_ver="$(ls | grep "^binutils-" | sed "s/binutils-//g")"
clang_version="$(install/bin/clang --version | head -n1 | cut -d' ' -f4)"

# Push to GitHub
# Update Git repository
git config --global user.name "ElectroPerf"
git config --global user.email "kunmun.devroms@gmail.com"
git clone "git@github.com:Neutron-Clang/neutron-toolchain.git" rel_repo
pushd rel_repo || exit
rm -fr ./*
cp -r ../install/* .
git checkout README.md # keep this as it's not part of the toolchain itself
git add .
git commit -asm "Import Neutron Clang Build Of $rel_friendly_date

Build completed on: $rel_friendly_date
LLVM commit: $llvm_commit_url
Clang Version: $clang_version
Binutils version: $binutils_ver
Builder commit: https://github.com/Neutron-Clang/build/commit/$builder_commit"
git push -f
popd || exit
