#!/bin/bash

source "$(dirname "${BASH_SOURCE[0]}")/../../../_gitignore/project-config"

SOURCE_FILE1="deploy_laravel_project"
#SOURCE_FILE2="reset_qr_inventory_transfer"

SOURCE_PATH="$(dirname "${BASH_SOURCE[0]}")/../server"

PERMISSIONS="--chown=root:root --chmod=0770"
DESTINATION_PATH="/usr/local/bin"

PRODUCTION_USER="root"
STAGING_USER="root"

usage() {
    echo "Syntax: $(basename "${BASH_SOURCE[0]}") [DESTINATION]"
    echo 'DESTINATION: all / production / staging (default: all)'
}

# check files exist
if [ ! -f $SOURCE_PATH/$SOURCE_FILE1 ]; then
    echo "Error: $SOURCE_PATH/$SOURCE_FILE1 file not found" 1>&2
    usage
    exit 1
fi
# if [ ! -f $SOURCE_PATH/$SOURCE_FILE2 ]; then
#     echo "Error: $SOURCE_PATH/$SOURCE_FILE2 file not found" 1>&2
#     usage
#     exit 1
# fi

DESTINATION=$1

# assign default value for empty argument
if [ $# -lt 1 ]; then
    DESTINATION="all"
fi

transfer_to_server() {
    SSH_USER=$1
    SSH_IP=$2

    rsync -vzhogpe "ssh -o StrictHostKeyChecking=no" --mkpath $PERMISSIONS $SOURCE_PATH/$SOURCE_FILE1 $SSH_USER@$SSH_IP:$DESTINATION_PATH/$SOURCE_FILE1
    #rsync -vzhogpe "ssh -o StrictHostKeyChecking=no" --mkpath $PERMISSIONS $SOURCE_PATH/$SOURCE_FILE2 $SSH_USER@$SSH_IP:$DESTINATION_PATH/$SOURCE_FILE2
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