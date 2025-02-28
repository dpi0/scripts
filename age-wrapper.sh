#!/bin/bash

# Get the script name
SCRIPT_NAME=$(basename "$0")

# Function to display help menu
display_help() {
    echo "Usage: $SCRIPT_NAME [options]"
    echo "Options:"
    echo "  -e, --encrypt /path/to/file   Encrypt the specified file or directory using the provided public key."
    echo "  -d, --decrypt /path/to/file   Decrypt the specified .age file using the provided private key."
    echo "  -k, --key /path/to/age.pub    Path to the age public or private key."
    echo "  -h, --help                    Display this help menu."
    echo ""
    echo "Examples:"
    echo "  $SCRIPT_NAME --key /path/to/age.pub --encrypt /path/to/file"
    echo "  $SCRIPT_NAME --key /path/to/age --decrypt /path/to/file.age"
    exit 1
}

# Function to ask for confirmation
ask_confirmation() {
    local prompt="$1"
    local response
    read -p "$prompt (y/n): " response
    case "$response" in
        [yY]|[yY][eE][sS]) return 0 ;;
        [nN]|[nN][oO]) return 1 ;;
        *) echo "Please answer y or n." ; ask_confirmation "$prompt" ;;
    esac
}

# Parse command line arguments
while [[ "$#" -gt 0 ]]; do
    case $1 in
        -e|--encrypt)
            ACTION="encrypt"
            FILE="$2"
            shift 2
            ;;
        -d|--decrypt)
            ACTION="decrypt"
            FILE="$2"
            shift 2
            ;;
        -k|--key)
            KEY="$2"
            shift 2
            ;;
        -h|--help)
            display_help
            ;;
        *)
            echo "Unknown parameter passed: $1"
            display_help
            ;;
    esac
done

# Validate required arguments
if [[ -z "$ACTION" || -z "$FILE" || -z "$KEY" ]]; then
    echo "Error: Missing required arguments."
    display_help
fi

# Validate key type based on action
if [[ "$ACTION" == "encrypt" ]]; then
    if [[ "$KEY" != *.pub ]]; then
        echo "Error: Public key must be provided for encryption."
        exit 1
    fi

    if [[ -d "$FILE" ]]; then
        if ask_confirmation "Provided a directory instead of a file. Convert it to a tar ball?"; then
            TAR_FILE="${FILE}.tar"
            echo "Compressing $FILE to $TAR_FILE..."
            tar -cf "$TAR_FILE" "$FILE"
            FILE="$TAR_FILE"
        else
            echo "Skipping encryption."
            exit 0
        fi
    fi

    OUTPUT_FILE="${FILE}.age"
    if [[ -f "$OUTPUT_FILE" ]]; then
        if ask_confirmation "File $OUTPUT_FILE already exists. Do you want to overwrite it?"; then
            echo "Encrypting $FILE using $KEY..."
            age -R "$KEY" "$FILE" > "$OUTPUT_FILE"
            echo "File encrypted and saved as $OUTPUT_FILE"
        else
            echo "Skipping encryption."
        fi
    else
        echo "Encrypting $FILE using $KEY..."
        age -R "$KEY" "$FILE" > "$OUTPUT_FILE"
        echo "File encrypted and saved as $OUTPUT_FILE"
    fi
elif [[ "$ACTION" == "decrypt" ]]; then
    if [[ "$KEY" == *.pub ]]; then
        echo "Error: Private key must be provided for decryption."
        exit 1
    fi

    if [[ -d "$FILE" ]]; then
        echo "Error: The input file for decryption cannot be a directory."
        exit 1
    fi

    if [[ "$FILE" != *.age ]]; then
        echo "Error: The input file for decryption must be a .age file."
        exit 1
    fi

    OUTPUT_FILE="${FILE%.age}"
    if [[ -f "$OUTPUT_FILE" ]]; then
        if ask_confirmation "File $OUTPUT_FILE already exists. Do you want to overwrite it?"; then
            echo "Decrypting $FILE with $KEY..."
            age -d -i "$KEY" "$FILE" > "$OUTPUT_FILE"
            echo "File decrypted and saved as $OUTPUT_FILE"
        else
            echo "Skipping decryption."
        fi
    else
        echo "Decrypting $FILE with $KEY..."
        age -d -i "$KEY" "$FILE" > "$OUTPUT_FILE"
        echo "File decrypted and saved as $OUTPUT_FILE"
    fi
else
    echo "Error: Invalid action specified."
    display_help
fi
