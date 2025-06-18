#!/bin/bash
set -ex

# This script is assumed to be used inside https://github.com/pypa/manylinux.

TARGET_TRIPLE=$(rustc -vV | awk '/^host/ {print $2}')
PROFDATA=/tmp/sudachi-profdata

# Compile Binary that will generate PGO data
RUSTFLAGS="-C profile-generate=$PROFDATA -C opt-level=3" \
  cargo build --release -p sudachi-cli 
  # --target=$TARGET_TRIPLE

# Download Kyoto Leads corpus original texts
curl -L https://github.com/ku-nlp/KWDLC/releases/download/release_1_0/leads.org.txt.gz | gzip -dc > leads.txt

# Generate Profile
target/release/sudachi -o /dev/null leads.txt
target/release/sudachi --wakati --mode=A -o /dev/null leads.txt
target/release/sudachi --all --mode=B -o /dev/null leads.txt
# target/$TARGET_TRIPLE/release/sudachi -o /dev/null leads.txt
# target/$TARGET_TRIPLE/release/sudachi --wakati --mode=A -o /dev/null leads.txt
# target/$TARGET_TRIPLE/release/sudachi --all --mode=B -o /dev/null leads.txt

# Generate Merged PGO data
"$HOME/.rustup/toolchains/stable-$TARGET_TRIPLE/lib/rustlib/$TARGET_TRIPLE/bin/llvm-profdata" \
  merge -o /tmp/sudachi-profdata.merged "$PROFDATA"
