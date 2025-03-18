#!/usr/bin/env bash

[ -d .git ] || git init

curl -fsSL https://bin.dpi0.cloud/license -o LICENSE

[ -f README.md ] || echo -e "# Project Title\n\nA brief description of the project." > README.md

echo "🟢 Ran git init. Created LICENSE and README.md"
