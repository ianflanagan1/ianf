#!/bin/bash

source "$(dirname "${BASH_SOURCE[0]}")/../../../_gitignore/project-config"

SOURCE_FILE="jenkins"
SOURCE_PATH="$(dirname "${BASH_SOURCE[0]}")/../../server-config/sudoers.d"
SOURCE_FILE_PATH="$SOURCE_PATH/$SOURCE_FILE"

PERMISSIONS="--chown=root:root --chmod=0644"
DESTINATION_FILE_PATH="/etc/sudoers.d/$SOURCE_FILE"

PRODUCTION_USER="root"
STAGING_USER="root"

usage() {
    echo "Syntax: $(basename "${BASH_SOURCE[0]}") [DESTINATION]"
    echo 'DESTINATION: all / production / staging (default: all)'
}

# check file exist
if [ ! -f $SOURCE_FILE_PATH ]; then
    echo "Error: $SOURCE_FILE_PATH file not found" 1>&2
    usage
    exit 1
fi

DESTINATION=$1

# assign default value for empty argument
if [ $# -lt 1 ]; then
    DESTINATION="all"
fi

transfer_to_server() {
    SSH_USER=$1
    SSH_IP=$2

    rsync -vzhogpe "ssh -o StrictHostKeyChecking=no" --mkpath $PERMISSIONS $SOURCE_FILE_PATH $SSH_USER@$SSH_IP:$DESTINATION_FILE_PATH
}

transfer_to_production() {
    transfer_to_server $PRODUCTION_USER $PRODUCTION_IP
}
transfer_to_staging() {
    transfer_to_server $STAGING_USER $STAGING_IP
}

case $DESTINATION in
    all)
        transfer_to_production
        transfer_to_staging
        ;;
    production)
        transfer_to_production
        ;;
    staging)
        transfer_to_staging
        ;;
    *)
        echo "Error: invalid DESTINATION" 1>&2
        usage
        exit 3
        ;;
esac