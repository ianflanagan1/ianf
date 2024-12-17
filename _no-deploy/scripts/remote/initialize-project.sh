#!/bin/bash

source "$(dirname "${BASH_SOURCE[0]}")/../../../_gitignore/project-config"

PRODUCTION_USER="root"
STAGING_USER="root"
JENKINS_USER="root"

usage() {
    echo "Syntax: $(basename "${BASH_SOURCE[0]}") [DESTINATION]"
    echo 'DESTINATION: all / production / staging / jenkins (default: all)'
}

if [ $# -lt 1 ]; then
    DESTINATION="all"
else
    DESTINATION=$1
fi

initialize_on_server() {
    SSH_USER=$1
    SSH_IP=$2
    ENVIRONMENT_NAME=$3

    ssh $SSH_USER@$SSH_IP << EOF
        if ! getent group "$PROJECT_NAME" >/dev/null; then
            groupadd "$PROJECT_NAME"
        fi

        if ! getent passwd jenkins >/dev/null; then
            useradd -m -s /bin/bash -G "$PROJECT_NAME" jenkins
            install -m 0700 -o jenkins -g jenkins -d /home/jenkins/.ssh
            install -m 0600 -o jenkins -g jenkins /dev/null /home/jenkins/.ssh/authorized_keys
        else
            usermod -aG "$PROJECT_NAME" jenkins
        fi

        install -m 0550 -o www-data -g "$PROJECT_NAME" -d "/var/www/$PROJECT_NAME" "/var/www/$PROJECT_NAME/$ENVIRONMENT_NAME" "/var/www/$PROJECT_NAME/$ENVIRONMENT_NAME/deploy"
        install -m 0570 -o www-data -g "$PROJECT_NAME" -d "/var/www/$PROJECT_NAME/$ENVIRONMENT_NAME/releases" "/var/www/$PROJECT_NAME/$ENVIRONMENT_NAME/releases/0" "/var/www/$PROJECT_NAME/$ENVIRONMENT_NAME/releases/0/public"
        install -m 0644 -o www-data -g "$PROJECT_NAME" <(echo "<?php echo 'hello';") "/var/www/$PROJECT_NAME/$ENVIRONMENT_NAME/releases/0/public/index.php"
        install -m 0755 -o root -g root -d "/etc/nginx/includes" "/etc/nginx/includes/root_directories"
        echo "root /var/www/$PROJECT_NAME/$ENVIRONMENT_NAME/releases/0/public;" > "/etc/nginx/includes/root_directories/$PROJECT_NAME-$ENVIRONMENT_NAME"
        install -m 0555 -o root -g "$PROJECT_NAME" -d "/var/log/$PROJECT_NAME" "/var/log/$PROJECT_NAME/$ENVIRONMENT_NAME"
        ln -snf /etc/nginx/sites-available/$PROJECT_NAME-$ENVIRONMENT_NAME /etc/nginx/sites-enabled/$PROJECT_NAME-$ENVIRONMENT_NAME

        nginx -s reload
        service php8.3-fpm reload
EOF

initialize_on_production() {
    initialize_on_server $PRODUCTION_USER $PRODUCTION_IP "production"
}

initialize_on_staging() {
    initialize_on_server $STAGING_USER $STAGING_IP "staging"
}

initialize_on_jenkins() {
    ssh $JENKINS_USER@$JENKINS_IP << EOF
        if [ ! -d /var/lib/jenkins/project-files ]; then
            install -m 0755 -o jenkins -g jenkins -d /var/lib/jenkins/project-files
        ]

        install -m 0700 -o jenkins -g jenkins -d "/var/lib/jenkins/project-files/$PROJECT_NAME"
        install -m 0500 -o jenkins -g jenkins -d "/var/lib/jenkins/project-files/$PROJECT_NAME/env-files"
EOF
}

case "$DESTINATION" in
    all)
        initialize_on_production
        initialize_on_staging
        initialize_on_jenkins
        ;;
    production)
        initialize_on_production
        ;;
    staging)
        initialize_on_staging
        ;;
    jenkins)
        initialize_on_jenkins
        ;;
    *)
        echo "Error: invalid DESTINATION" 1>&2
        usage
        exit 3
        ;;
esac