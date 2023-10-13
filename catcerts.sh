#!/bin/bash
# concatenate a server cert and the chain (or root cert) into a single file

## Usage info
show_help() {
cat << EOF
Usage: ${0##*/} [-h] -k KEY -c CHAIN [-o PEM] <certificate>
This script concatenates a certificate with root, intermediate and/or key.
Either a Key or Chain file must be provided.

    -k KEY      Certificate key file.
    -c CHAIN    Chain or root certificate file.
    -o PEM      Output pem path or file(path). Defaults to:
                Chain: <certificate>.full.pem
                KEY: <certificate>.pem
    -h          Display this help and exit.
EOF
}

## Fixed variables
OPTIND=1

## Read/interpret optional arguments
while getopts k:c:0:h opt; do
    case $opt in
        k)  KEY=$OPTARG
            ;;
        c)  CHAIN=$OPTARG
            ;;
        o)  PEM=$OPTARG
            ;;
        *)  show_help >&2
            exit 1
            ;;
    esac
done
shift "$((OPTIND-1))"   # Discard the options and sentinel --

## This script must be run as root
if [ "$EUID" -ne 0 ]; then
    echo "Please run as root"
    exit
fi

# Check that source files are available
if [ -z "$@" ]; then
    printf "ERROR: No certificate given.\n\n"
    show_help >&2
    exit 1
else
    if [ ! -f "$@" ]; then
        echo "ERROR: Certificate not found: $@"
        exit 2
    elif [ -n "$KEY" ] || [ -n "$CHAIN" ]; then
        if [ -n "$KEY" ] && [ ! -f "$KEY" ]; then
            echo "ERROR: Key not found: $KEY"
            exit 2
        fi
        if [ -n "$CHAIN" ] && [ ! -f "$CHAIN" ]; then
            echo "ERROR: Chain not found: $CHAIN"
            exit 2
        fi
        CRT="$@"
    else
        echo "ERROR: Either a key or chain file must be parsed, found neither."
        exit 1
    fi
fi

# Build pem path and filename
if [ -n "$PEM" ]; then
    if [ -d "$PEM" ]; then
        # Output path was provided
        PEM_OUT="$PEM/$(basename "${CRT%.*}")"
    elif [ -d "$(dirname "$PEM")" ]; then
        # Output file was provided
        PEM_OUT="$PEM"
    else
        echo "ERROR: Path does not exist: $PEM"
        exit 2
    fi
else
    # Use CRT file to make up PEM filename & path
    PEM_OUT="$(dirname "$CRT")/$(basename -s "${CRT%.*}")"
fi

# Test if the CRT file has a pem extension that will conflict with output
if [[ "$CRT" == "${PEM_OUT}.pem" ]]; then
    echo "ERROR: Output will overwrite the source certificate, concatenation aborted."
    echo "### An output file must be provided with a different path or filename."
    exit 1
else
    # Concatenate the files
    $PEM_OUT="${PEM_OUT}.pem"
    touch "$PEM_OUT"
    [ -f "$KEY" ] && cat "$KEY" >> "$PEM_OUT"
    [ -f "$CRT" ] && cat "$CRT" >> "$PEM_OUT"
    [ -f "$CHAIN" ] && cat "$CHAIN" >> "$PEM_OUT"
fi

# Check the file isn't empty
if [ -s "$PEM_OUT" ]; then
    # Protect file if it contains a key
    [ -f "$KEY" ] && chmod 600 "$PEM_OUT"
else
    rm "$PEM_OUT"
    echo "FAILED: The output was empty. Removed file: $PEM_OUT"
fi
echo "DONE: Concatenated file: $PEM_OUT"
