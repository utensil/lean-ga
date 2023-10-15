#!/bin/bash

# if uname -o return a string containing Linux with optional prefixes or postfixes



if [ "$(uname -m)" = "aarch64" ]; then
    if [[ "$(uname -o)" == *"Linux"* ]]; then
        curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y
        source "$HOME/.cargo/env"
        sudo apt install -y pkg-config libssl-dev libicu-dev libgraphite2-dev libfreetype6-dev libfontconfig1-dev
        cargo install tectonic
        cp $HOME/.cargo/bin/tectonic $HOME/.local/bin/tectonic
        exit 0
    else
        echo "Tectonic is not supported on this platform"
        exit 1
    fi
else
    # Install Tectonic
    mkdir -p ~/.local/bin
    (cd ~/.local/bin && curl --proto '=https' --tlsv1.2 -fsSL https://drop-sh.fullyjustified.net |sh)
    which tectonic
    exit 0
fi

