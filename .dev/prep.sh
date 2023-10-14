#!/bin/bash

SCRIPTS_DIR=$(cd $(dirname "$0") && pwd)
echo "SCRIPTS_DIR=$SCRIPTS_DIR"
ROOT="$SCRIPTS_DIR/../"
mkdir -p $ROOT/
ROOT=$(cd $ROOT && pwd)
echo "ROOT=$ROOT"

cd $ROOT

sudo apt update
sudo apt install -y curl wget git git-lfs python3 python3-pip graphviz libgraphviz-dev pdf2svg dvisvgm texlive-binaries # texlive-full

# Install Tectonic
mkdir -p ~/.local/bin
(cd ~/.local/bin && curl --proto '=https' --tlsv1.2 -fsSL https://drop-sh.fullyjustified.net |sh)
which tectonic

curl https://raw.githubusercontent.com/leanprover/elan/master/elan-init.sh -sSf | bash -s -- -y
source ~/.profile
pip install -r requirements.txt

# mkdir -p ~/.local/bin
# cd ~/.local/bin
# curl --proto '=https' --tlsv1.2 -fsSL https://drop-sh.fullyjustified.net |sh

cd $ROOT

