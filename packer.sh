#!/bin/bash

# Error handler accepts message and optional line number.
trap 'error_handler $? $LINENO' ERR
error_handler() {
    RED=$(tput setaf 1)
    YELLOW=$(tput setaf 3)
    NC=$(tput sgr0)

    message="${RED}Error: ${YELLOW}$1${NC}"
    [ -n "$2" ] && message+=" at line $2"

    echo -e $message 1>&2
    exit 1
}

# Help message for the script.
help(){
    echo "Usage: ${0##*/} [--help] [--build|build] --os <os name> --os-version <os version> [--log <path>] [--build-option <packer options>] "
    echo
    echo "Options:"
    echo "  --build build                           Run 'packer build' defualt action is to validate."
    echo "  --build-options <packer options>        Pass additonal options to 'packer build'.  For a full list use 'packer build --help.'"
    echo "  --log -l <path>                         Create a packer build log with the given path."
    echo "  --os <operating system>                 Required option indicating the operating system."
    echo "  --os-version                            Required option indicating the version of the operating system."
    echo
    exit 0
}

# Test if given file is encrypted with sops.
test_sops(){
    local file=${1:?}
    [ -f "$file" ] || exit
    if grep -q -e "^sops_" "$file"; then
        echo 'true'
    else
        echo 'false'
    fi
}

# Parse command line options.
while [ $# -gt 0 ] ; do
    case $1 in
        --build | build) build="true" ;;
        --build-option) options="$2"; shift ;;
        --help | -h) help;;
        --log | -l) log="$2"; shift ;;
        --os) os="$2"; shift ;;
        --os-version) os_version="$2"; shift ;;
        *) error_handler "Unknown parameter '$1'. Use '${0##*/} --help'" ;;
    esac
    shift
done

# Get required parameters if they were not in the command line.
if [ -z "${os}" ]; then
    read -p "Operating System: " os
fi

if [ -z "$os_version" ]; then
    read -p "Version: " os_version
fi

# Set log file variables if log argument was provided.
if [ -n "$log" ]; then
    export PACKER_LOG=10
    export PACKER_LOG_PATH="$log"
fi

# Throw an error if packer is not installed.
command -v packer > /dev/null || error_handler "Packer not installed."

# Define script variables.
SCRIPTDIR=$(dirname "${BASH_SOURCE[0]}")
varfile=$SCRIPTDIR/$os/$os-$os_version.pkrvars.hcl
secrets=$SCRIPTDIR/$os/$os-$os_version.secrets.env
proxmox=$SCRIPTDIR/proxmox.secrets.env

# Throw an error if the given OS and or OS version don't exist.
[ -d "$SCRIPTDIR/$os" ] || error_handler "Unsupported Operating System: '$os'"
[ -f "$varfile" ] || error_handler "Unsupported OS Version: '$os_version'. Var-file: '$varfile' does not exist."

# Check if the secret files are encrypted.  If they are, verify SOPS and AGE are installed and configured.
if [ "$(test_sops "$secrets")" = "true" ] && [ "$(test_sops "$proxmox")" = "true" ]; then
    command -v sops > /dev/null || error_handler "SOPS not installed." $LINENO
    command -v age > /dev/null || error_handler "AGE not installed." $LINENO
    [ -n "$SOPS_AGE_KEY_FILE" ] || error_handler "AGE key file variable, SOPS_AGE_KEY_FILE undefined." $LINENO
fi

# Export OS environment varibles.
if [ "$(test_sops "$secrets")" = "true" ]; then
    export $(sops --decrypt --age $(awk '/public key:/{print $NF}' $SOPS_AGE_KEY_FILE) $secrets | grep -v "^#" | xargs)
elif [ "$(test_sops "$secrets")" = "false" ]; then
    export $(grep -v "^#" $secrets | xargs)
fi

# Export Proxmox environment variables.
if [ "$(test_sops "$proxmox")" = "true" ]; then
    export $(sops --decrypt --age $(awk '/public key:/{print $NF}' $SOPS_AGE_KEY_FILE) $proxmox | grep -v "^#" | xargs)
elif [ "$(test_sops "$proxmox")" = "false" ]; then
    export $(grep -v "^#" $proxmox | xargs)
fi

# If PKR_VAR_SSH_PASSWORD exist create a hashed password with Python.
if [ -n "$PKR_VAR_SSH_PASSWORD" ]; then
    command -v python3 > /dev/null || error_handler "Python 3 not installed." $LINENO
    python3 -c "import passlib" &> /dev/null || error_handler "Python package passlib is not installed." $LINENO

    export SSH_PASSWORD_HASH=$(python3 -c "\
from passlib.hash import sha512_crypt; \
print(sha512_crypt.hash('$PKR_VAR_SSH_PASSWORD'))")
fi

# Any files with .envsubst file extension will undergo environment variable replacment.
# The replacement file will strip the .envsubst file extension.
if [ -n "$(find $SCRIPTDIR/$os -name '*.envsubst')" ]; then
    command -v envsubst > /dev/null || error_handler "Envsubst not installed." $LINENO
    find "$SCRIPTDIR/$os" -name '*.envsubst' -exec sh -c 'envsubst < "$1" > "${1%.envsubst}"' _ {} \;
fi

# Intialize packer.
packer init $os

# Validate by default; build if the argment was provided.
if [[ -n "$build" && $build = "true" ]]; then
    packer build $options -var-file=$varfile $os
else
    packer validate -var-file=$varfile $os
fi
