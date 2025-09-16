#!/bin/bash

# Install issue-plan-sagent command to global opencode config
mkdir -p ~/.config/opencode/command
cp -r command/orch.md ~/.config/opencode/command/
echo "ORCH command installed to ~/.config/opencode/command/"
