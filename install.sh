#!/bin/bash
# curl https://raw.githubusercontent.com/EtienneMR/sc-scripts/main/install.sh | bash

set -euo pipefail

DIR="$HOME/.local/apps/sc"


if [ -d "$DIR" ]
then
    echo "!  Installation already found in $DIR"
    echo "   Updating using sc self update"
    exec python "$DIR/sc/__main__.py" self update
else
    echo "   Installing in $DIR"
    mkdir -p "$DIR"
    git clone https://github.com/EtienneMR/sc-scripts "$DIR"
    exec python "$DIR/sc/__main__.py" self install
fi
