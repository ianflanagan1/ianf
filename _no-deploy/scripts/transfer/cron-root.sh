#!/bin/bash

source "$(dirname "${BASH_SOURCE[0]}")/../../../_gitignore/project-config"

PRODUCTION_USER="root"
STAGING_USER="root"

usage() {
    echo "Syntax: $(basename "${BASH_SOURCE[0]}") [DESTINATION]"
    echo 'DESTINATION: all / production / staging (default: all)'
}

if [ $# -lt 1 ]; then
    DESTINATION="all"
else
    DESTINATION=$1
fi

SOURCE_PATH="$(dirname "${BASH_SOURCE[0]}")/../../server-config/cron-root"
PERMISSIONS="--chown=root:root --chmod=0440"
DESTINATION_FILE_PATH="/var/spool/cron/crontabs/root"

transfer_to_server() {
    SSH_USER=$1
    SSH_IP=$2
    ENVIRONMENT_NAME=$3

    SOURCE_FILE_PATH="$SOURCE_PATH/$ENVIRONMENT_NAME"

    rsync -vzhogpe "ssh -o StrictHostKeyChecking=no" --mkpath $PERMISSIONS $SOURCE_FILE_PATH $SSH_USER@$SSH_IP:$DESTINATION_FILE_PATH
}

transfer_to_production() {
    transfer_to_server $PRODUCTION_USER $PRODUCTION_IP "production"
}

transfer_to_staging() {
    transfer_to_server $STAGING_USER $STAGING_IP "staging"
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