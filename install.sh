#!/bin/bash
# curl https://raw.githubusercontent.com/EtienneMR/sc-scripts/main/install.sh | bash

set -euo pipefail

DIR="$HOME/.local/apps/sc-scripts"


if [ -d "$DIR" ]
then
    echo "!  Installation already found in $DIR"
    echo "   Updating using sc-update"
    exec bash "$DIR/bin/sc-update"
else
    echo "   Installing in $DIR"
    mkdir -p "$DIR"
    git clone https://github.com/EtienneMR/sc-scripts "$DIR"
    exec bash "$DIR/bootstrap.sh"
fi
