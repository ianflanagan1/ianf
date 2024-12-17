#!/bin/bash

source "$(dirname "${BASH_SOURCE[0]}")/../../../_gitignore/project-config"

PRODUCTION_FILE="production.ssl"
STAGING_FILE="staging.ssl"

SOURCE_PATH="$(dirname "${BASH_SOURCE[0]}")/../../server-config/nginx"

PRODUCTION_FILE_PATH="$SOURCE_PATH/$PRODUCTION_FILE"
STAGING_FILE_PATH="$SOURCE_PATH/$STAGING_FILE"

PRODUCTION_USER="root"
STAGING_USER="root"

usage() {
    echo "Syntax: $(basename "${BASH_SOURCE[0]}") [DESTINATION]"
    echo 'DESTINATION: all / production / staging (default: all)'
}

# check nginx conf files exist
if [ ! -f $PRODUCTION_FILE_PATH ]; then
    echo "Error: $PRODUCTION_FILE_PATH file not found" 1>&2
    usage
    exit 1
fi
if [ ! -f $STAGING_FILE_PATH ]; then
    echo "Error: $STAGING_FILE_PATH file not found" 1>&2
    usage
    exit 2
fi

DESTINATION=$1

# assign default value for empty argument
if [ $# -lt 1 ]; then
    DESTINATION="all"
fi

PERMISSIONS="--chown=www-data:$PROJECT_NAME --chmod=0640"

transfer_to_server() {
    SSH_USER=$1
    SSH_IP=$2
    ENVIRONMENT_NAME=$3
    SOURCE_FILE_PATH=$4

    DESTINATION_FILE_PATH="/etc/nginx/sites-available/$PROJECT_NAME-$ENVIRONMENT_NAME"

    rsync -vzhogpe "ssh -o StrictHostKeyChecking=no" --mkpath $PERMISSIONS $SOURCE_FILE_PATH $SSH_USER@$SSH_IP:$DESTINATION_FILE_PATH
}

transfer_to_production() {
    transfer_to_server $PRODUCTION_USER $PRODUCTION_IP "production" $PRODUCTION_FILE_PATH
}
transfer_to_staging() {
    transfer_to_server $STAGING_USER $STAGING_IP "staging" $STAGING_FILE_PATH
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