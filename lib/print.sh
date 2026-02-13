#!/usr/bin/env zsh

# Function to print messages with color
# Arg 1: Message to print
function print() {
    echo -e "$1"
}

# Function to print success messages
# Arg 1: Message to print
function print_success() {
    echo -e "\033[0;32m$1\033[0m"
}

# Function to print error messages
# Arg 1: Message to print
function print_error() {
    echo -e "\033[0;31m$1\033[0m"
}

# Function to print warning messages
# Arg 1: Message to print
function print_warning() {
    echo -e "\033[0;33m$1\033[0m"
}

# Function to print info messages
# Arg 1: Message to print
function print_info() {
    echo -e "\033[0;34m$1\033[0m"
}
