#!/usr/bin/env zsh

source "$(dirname $0)/print.sh"

# Function to create symbolic links
# Arg 1: Source path
# Arg 2: Destination path
function create_symlink() {
    local src="${1}"
    local dst="${2}"

    if [[ -e "${dst}" ]]; then
        if [[ -L "${dst}" ]]; then
            local current_target=$(readlink "${dst}")

            if [[ "${current_target}" = "${src}" ]]; then
                print "Link already exists (skipping): ${dst} -> ${src}"
                return 0
            else
                print_warning "Link exists with different target: ${dst} -> ${current_target}"
                print_warning "Updating to new link: ${dst} -> ${src}"
                rm -f "${dst}"
            fi
        else
            print_warning "Regular file exists at destination: ${dst}"
            print_warning "Creating backup: ${dst}.bak"
            mv "${dst}" "${dst}.bak"
        fi
    fi

    ln -s "${src}" "${dst}"
    print_info "Created link: ${dst} -> ${src}"
}
