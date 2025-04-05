#!/usr/bin/env zsh

# Check if command is available
# Arg 1: Command name
function is_command_available() {
    command -v "$1" >/dev/null 2>&1
}
