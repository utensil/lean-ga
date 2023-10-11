#!/bin/bash

SCRIPTS_DIR=$(cd $(dirname "$0") && pwd)
ROOT="$SCRIPTS_DIR/../"
mkdir -p $WORKSPACES/
ROOT=$(cd $ROOT && pwd)
echo "ROOT=$ROOT"

sudo docker run -d --name lean-ga -v$ROOT:/workspaces/lean-ga/ mcr.microsoft.com/devcontainers/base:ubuntu bash -c 'sleep infinity'
