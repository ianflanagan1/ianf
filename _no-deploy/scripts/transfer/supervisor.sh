#!/bin/bash

source "$(dirname "${BASH_SOURCE[0]}")/../../../_gitignore/project-config"

PRODUCTION_USER="root"
STAGING_USER="root"

usage() {
    echo "Syntax: $(basename "${BASH_SOURCE[0]}") [-u/-r] [DESTINATION]"
    echo 'DESTINATION: all / production / staging (default: all)'
    echo '-u  supervisor update (enact new config)'
    echo '-r  supervisor reread (do not enact new config)'
}

SUPERVISOR_UPDATE=false
SUPERVISOR_REREAD=false

POSITIONAL_ARGUMENTS=()

while [[ $# -gt 0 ]]; do
    case $1 in
    -u)
        SUPERVISOR_UPDATE=true
        shift
        ;;
    -r)
        SUPERVISOR_REREAD=true
        shift
        ;;
    -*|--*)
        echo 'Error: invalid option'
        usage
        exit 1
        ;;
    *)
        POSITIONAL_ARGUMENTS+=("$1")
        shift
        ;;
    esac
done

set -- "${POSITIONAL_ARGUMENTS[@]}"

if [ $# -lt 1 ]; then
    DESTINATION="all"
else
    DESTINATION=$1
fi

PERMISSIONS="--chown=root:root --chmod=0440"
DESTINATION_PATH="/etc/supervisor/conf.d"

transfer_to_server() {
    SSH_USER=$1
    SSH_IP=$2
    ENVIRONMENT_NAME=$3

    SOURCE_FILE_PATH="$(dirname "${BASH_SOURCE[0]}")/../supervisor/$ENVIRONMENT_NAME"
    DESTINATION_FILE_PATH="$DESTINATION_PATH/$PROJECT_NAME-$ENVIRONMENT_NAME.conf"

    rsync -vzhogpe "ssh -o StrictHostKeyChecking=no" --mkpath $PERMISSIONS $SOURCE_FILE_PATH $SSH_USER@$SSH_IP:$DESTINATION_FILE_PATH

    if [ $SUPERVISOR_UPDATE = true ]; then
        ssh $SSH_USER@$SSH_IP "supervisorctl update"
    else
        if [ $SUPERVISOR_REREAD = true ]; then
            ssh $SSH_USER@$SSH_IP "supervisorctl reread"
        fi
    fi
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