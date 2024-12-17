#!/bin/bash

source "$(dirname "${BASH_SOURCE[0]}")/../../../_gitignore/project-config"

SOURCE_PATH="$(dirname "${BASH_SOURCE[0]}")/../../../_gitignore/env-files"

PRODUCTION_FILE=".env.production"
STAGING_FILE=".env.staging"
TESTING_FILE=".env.testing"

PRODUCTION_FILE_PATH="$SOURCE_PATH/$PRODUCTION_FILE"
STAGING_FILE_PATH="$SOURCE_PATH/$STAGING_FILE"
TESTING_FILE_PATH="$SOURCE_PATH/$TESTING_FILE"

PRODUCTION_USER="root"
STAGING_USER="root"
JENKINS_USER="root"

usage() {
    echo "Syntax: $(basename "${BASH_SOURCE[0]}") [DESTINATION]"
    echo 'DESTINATION: all / production / staging / jenkins (default: all)'
}

# check .env files exist
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
if [ ! -f $TESTING_FILE_PATH ]; then
    echo "Error: $TESTING_FILE_PATH file not found" 1>&2
    usage
    exit 2
fi

DESTINATION=$1

# assign default value for empty argument
if [ $# -lt 1 ]; then
    DESTINATION="all"
fi

transfer_to_server() {
    SSH_USER=$1
    SSH_IP=$2
    ENVIRONMENT_NAME=$3
    SOURCE_FILE_PATH=$4

    PERMISSIONS="--chown=www-data:$PROJECT_NAME --chmod=0400"
    DESTINATION_FILE_PATH="/var/www/$PROJECT_NAME/$ENVIRONMENT_NAME/deploy/.env"
    rsync -vzhogpe "ssh -o StrictHostKeyChecking=no" --mkpath $PERMISSIONS $SOURCE_FILE_PATH $SSH_USER@$SSH_IP:$DESTINATION_FILE_PATH
}

transfer_to_production() {
    transfer_to_server $PRODUCTION_USER $PRODUCTION_IP "production" $PRODUCTION_FILE_PATH
}

transfer_to_staging() {
    transfer_to_server $STAGING_USER $STAGING_IP "staging" $STAGING_FILE_PATH
}

transfer_to_jenkins() {
    PERMISSIONS="--chown=jenkins:jenkins --chmod=0400"
    DESTINATION_PATH="/var/lib/jenkins/project-files/$PROJECT_NAME/env-files"
    #rsync -rvzhogpe "ssh -o StrictHostKeyChecking=no" --mkpath $PERMISSIONS $SOURCE_PATH/ $JENKINS_USER@$JENKINS_IP:$DESTINATION_PATH
    rsync -vzhogpe "ssh -o StrictHostKeyChecking=no" --mkpath $PERMISSIONS $PRODUCTION_FILE_PATH $SSH_USER@$SSH_IP:$DESTINATION_PATH
    rsync -vzhogpe "ssh -o StrictHostKeyChecking=no" --mkpath $PERMISSIONS $STAGING_FILE_PATH $SSH_USER@$SSH_IP:$DESTINATION_PATH
    rsync -vzhogpe "ssh -o StrictHostKeyChecking=no" --mkpath $PERMISSIONS $TESTING_FILE_PATH $SSH_USER@$SSH_IP:$DESTINATION_PATH
}

case $DESTINATION in
    all)
        transfer_to_production
        transfer_to_staging
        transfer_to_jenkins
        ;;
    production)
        transfer_to_production
        ;;
    staging)
        transfer_to_staging
        ;;
    jenkins)
        transfer_to_jenkins
        ;;
    *)
        echo "Error: invalid DESTINATION" 1>&2
        usage
        exit 3
        ;;
esac