#!/bin/bash

# Global variables
SCRIPT_NAME=$(basename "$0")
KEY_FILE="$HOME/.ssh/age-key.pub"
INPUT_DIR=""
DELETE_TAR=false
ONLY_TAR=false

# Function to display help menu
show_help() {
    echo "Usage: $SCRIPT_NAME [options]"
    echo "Options:"
    echo "  -k, --key <path>        Path to the public key file (default: $HOME/.ssh/age-key.pub)"
    echo "  -i, --input <path>      Path to the input file or directory (required)"
    echo "      --delete-tar        Delete the tar file after successful encryption"
    echo "      --only-tar          Perform only tar -cvf and use that as input to age command"
    echo "  -h, --help              Display this help menu"
    exit 0
}

# Function to print colored messages
print_message() {
    local color="$1"
    local message="$2"
    case "$color" in
        red) echo -e "\e[31m$message\e[0m" ;;
        yellow) echo -e "\e[33m$message\e[0m" ;;
        green) echo -e "\e[32m$message\e[0m" ;;
        blue) echo -e "\e[34m$message\e[0m" ;;
        *) echo "$message" ;;
    esac
}

# Parse command line arguments
while [[ "$#" -gt 0 ]]; do
    case $1 in
        -k|--key) KEY_FILE="$2"; shift ;;
        -i|--input) INPUT_DIR="$2"; shift ;;
        --delete-tar) DELETE_TAR=true ;;
        --only-tar) ONLY_TAR=true ;;
        -h|--help) show_help ;;
        *) print_message red "Unknown parameter passed: $1"; show_help ;;
    esac
    shift
done

# Validate input directory
if [[ -z "$INPUT_DIR" ]]; then
    print_message red "Error: Input directory is required."
    show_help
fi

# Validate key file
if [[ ! -f "$KEY_FILE" ]]; then
    print_message red "Error: Key file does not exist."
    exit 1
elif [[ "$KEY_FILE" != *.pub ]]; then
    print_message red "Error: Key file must be a .pub file."
    exit 1
fi

print_message blue "Validating key file at $KEY_FILE"
print_message green "Key file validated successfully."

# Determine output file names
TAR_FILE="${INPUT_DIR}.tar"
TAR_XZ_FILE="${INPUT_DIR}.tar.xz"
AGE_FILE="${INPUT_DIR}.tar.xz.age"

# Create tar.xz file if it doesn't exist
if [[ ! -f "$TAR_XZ_FILE" ]]; then
    print_message blue "Compressing $INPUT_DIR to $TAR_XZ_FILE"
    if $ONLY_TAR; then
        tar -cvf "$TAR_FILE" "$INPUT_DIR"
        print_message green "Tar file created successfully: $TAR_FILE"
    else
        tar -cvJf "$TAR_XZ_FILE" "$INPUT_DIR"
        print_message green "Tar.xz file created successfully: $TAR_XZ_FILE"
    fi
else
    print_message yellow "Tar.xz file already exists: $TAR_XZ_FILE"
fi

# Encrypt the tar.xz file if it doesn't exist
if [[ ! -f "$AGE_FILE" ]]; then
    print_message blue "Encrypting $TAR_XZ_FILE with key at $KEY_FILE"
    if $ONLY_TAR; then
        age -R "$KEY_FILE" "$TAR_FILE" > "${TAR_FILE}.age"
        print_message green "Encryption completed: ${TAR_FILE}.age created."
    else
        age -R "$KEY_FILE" "$TAR_XZ_FILE" > "$AGE_FILE"
        print_message green "Encryption completed: $AGE_FILE created."
    fi
else
    print_message yellow "Encrypted file already exists: $AGE_FILE"
fi

# Delete the tar file if --delete-tar is specified
if $DELETE_TAR; then
    if $ONLY_TAR; then
        print_message blue "Deleting tar file: $TAR_FILE"
        rm "$TAR_FILE"
    else
        print_message blue "Deleting tar.xz file: $TAR_XZ_FILE"
        rm "$TAR_XZ_FILE"
    fi
fi

print_message green "Script completed successfully."
