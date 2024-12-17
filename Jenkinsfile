pipeline {
    agent any
    environment {
        PROJECT_NAME        = 'ianf'
        PHP_VERSION         = '8.3'

        TEST_COVERAGE_LIMIT = '0'

        DEPENDENCY_CACHES_TO_KEEP = 5
        SUCCESSFUL_RELEASES_TO_KEEP = 5

        PRODUCTION_IP       = '167.71.130.57'
        PRODUCTION_SSH_KEY  = 'production-id_ed25519'

        SSH_KEY_PATH        = "$HOME/.ssh"
        WEB_ROOT            = '/var/www'

        PROJECT_FILES_PATH       = "/var/lib/jenkins/project-files/$PROJECT_NAME"
        ENV_PATH                 = "$PROJECT_FILES_PATH/env-files"
        PRODUCTION_ENV_FILE_PATH = "$ENV_PATH/.env.production"
        STAGING_ENV_FILE_PATH    = "$ENV_PATH/.env.staging"
        TESTING_ENV_FILE_PATH    = "$ENV_PATH/.env.testing"
    }
    stages {
        stage('Test') {
            steps {
                // check .env exists on Jenkins server
                script {
                    if (!fileExists("$TESTING_ENV_FILE_PATH")) {
                        error("$TESTING_ENV_FILE_PATH missing from Jenkins server")
                    }
                }

                getComposerDependencies(false)
                getNodeDependencies()

                sh '''#!/bin/bash
                    set -eu

                    # build
                    npm run build
                    cp $TESTING_ENV_FILE_PATH .env
                    php artisan storage:link
                    php artisan optimize

                    # test
                    vendor/bin/pint -v
                    php artisan test --coverage --min=$TEST_COVERAGE_LIMIT
                    php artisan dusk:chrome-driver
                    # chmod -R 0755 vendor/laravel/dusk/bin
                    php artisan serve &
                    php artisan dusk
                '''
                // closing shell session to end 'php artisan serve &'
                sh '''#!/bin/bash
                    set -eu

                    # clean up
                    rm -rf vendor
                    rm -f .env storage/app/laravel.log database/database.sqlite public/storage

                    # if log exists, print log and fail the stage
                    if [ -s ./storage/app/laravel.log ]; then
                        echo './storage/app/laravel.log :'
                        cat ./storage/app/laravel.log
                        exit 1
                    fi
                '''
            }
        }

        stage('Deploy - Staging') {
            when { branch 'develop' }
            environment {
                ENVIRONMENT_NAME    = "staging"
                ENVIRONMENT_PATH    = "$WEB_ROOT/$PROJECT_NAME/$ENVIRONMENT_NAME"
                BUILD_PATH          = "$ENVIRONMENT_PATH/releases/${BUILD_NUMBER}"
                TAR_FILE            = "$PROJECT_NAME-$ENVIRONMENT_NAME-${BUILD_NUMBER}.tar.gz"
            }
            steps {
                // check .env exists on Jenkins server
                script {
                    if (!fileExists("$STAGING_ENV_FILE_PATH")) {
                        error("$STAGING_ENV_FILE_PATH file missing from Jenkins server")
                    }
                }

                getComposerDependencies(true)

                sh '''#!/bin/bash
                    set -eu

                    cp $STAGING_ENV_FILE_PATH .env
                    npm run build
                    rm -rf resources/css resources/js
                    tar -czf $TAR_FILE app bootstrap config database public resources routes storage vendor artisan composer.json
                    rsync -vzh --mkpath --chown=jenkins:jenkins --chmod=0700 $TAR_FILE $BUILD_PATH/$TAR_FILE

                    # SSH to "remote" server - but in this case jenkins and staging are on the same server
                        cd $BUILD_PATH
                        tar -xzf $TAR_FILE
                        rm -f $TAR_FILE

                        sudo /usr/local/bin/deploy_laravel_project $PROJECT_NAME $ENVIRONMENT_NAME ${BUILD_NUMBER} $PHP_VERSION $SUCCESSFUL_RELEASES_TO_KEEP
                '''
            }
        }

        stage('Deploy - Production') {
            when { branch 'main' }
            environment {
                ENVIRONMENT_NAME    = "production"
                ENVIRONMENT_PATH    = "$WEB_ROOT/$PROJECT_NAME/$ENVIRONMENT_NAME"
                BUILD_PATH          = "$ENVIRONMENT_PATH/releases/${BUILD_NUMBER}"
                TAR_FILE            = "$PROJECT_NAME-$ENVIRONMENT_NAME-${BUILD_NUMBER}.tar.gz"

                PRODUCTION_SSH_KEY_PATH  = "$SSH_KEY_PATH/$PRODUCTION_SSH_KEY"
            }
            steps {
                // check ssh key exists on Jenkins server
                script {
                    if (!fileExists("$PRODUCTION_SSH_KEY_PATH")) {
                        error("$PRODUCTION_SSH_KEY_PATH (ssh key) is missing from Jenkins server")
                    }
                }

                // check .env exists on Jenkins server
                script {
                    if (!fileExists("$PRODUCTION_ENV_FILE_PATH")) {
                        error("$PRODUCTION_ENV_FILE_PATH file missing from Jenkins server")
                    }
                }

                getComposerDependencies(true)

                sh '''#!/bin/bash
                    set -eu

                    cp $PRODUCTION_ENV_FILE_PATH .env
                    npm run build
                    rm -rf resources/css resources/js
                    tar -czf $TAR_FILE app bootstrap config database public resources routes storage vendor artisan composer.json
                    rsync -vzhe "ssh -i $PRODUCTION_SSH_KEY_PATH -o StrictHostKeyChecking=no" --mkpath --chown=jenkins:jenkins --chmod=0700 $TAR_FILE jenkins@$PRODUCTION_IP:$BUILD_PATH/$TAR_FILE

                    ssh -i $PRODUCTION_SSH_KEY_PATH jenkins@$PRODUCTION_IP << EOF
                        set -eu

                        cd $BUILD_PATH
                        tar -xzf $TAR_FILE
                        rm -f $TAR_FILE

                        sudo /usr/local/bin/deploy_laravel_project $PROJECT_NAME $ENVIRONMENT_NAME ${BUILD_NUMBER} $PHP_VERSION $SUCCESSFUL_RELEASES_TO_KEEP
                        # DEPLOYMENT SCRIPT - repo: ./_no-deploy/server-scripts/deploy_laravel_project
                        # - set files & directories to www-data:<project-name>
                        # - set files to 0440
                        # - set directories to 0550
                        # - set ./bootstrap/cache ./storage and ./database to 0770
                        # - create/set ./storage/logs/laravel.log and ./database/database.sqlite to 0660
                        # - copy .env file
                        # - php artisan storage:link
                        # - php artisan clear-compiled
                        # - php artisan optimize
                        # - create symlink to new build directory (for supervisor processes to reference)
                        # - stop supervisor workers
                        # - update nginx conf to point to the new build directory
                        # - restart php-fpm
                        # - start supervisor workers
                        # - mark release a success
                        # - delete unsuccessful releases
                        # - delete excess releases
EOF
                '''

                /*
                    --- NOTES ---

                    SUPERVISOR AND QUEUE WORKERS

                        1) Allows process to finish before stopping:
                            - supervisorctl restart
                            - supervisorctl stop

                        2) The same commands hold up terminal execution until jobs are done

                        3) When /etc/supervisor/conf.d configs reference a symlink:

                            DOES re-evaluate symlink destination:
                            - supervisorctl restart
                            - supervisorctl stop && supervisorctl start
                                - the ordering of supervisorctl stop and ln doesn't make a difference
                            - supervisorctl update if conf file has change

                            DOES NOT re-evaluate symlink destination:
                            - supervisorctl update if conf file has not change


                    SUPERVISOR AND REVERB / WEBSOCKET

                        1) no need to stop/start or restart after deploying new build

                        2) stop/start and restart
                            - browser eventually reconnects, but takes ~20 seconds
                            - but new requests connect immediately after restart
                */

            }
        }
    }
    post {
        always {
            cleanWs()
        }
    }
}

def getComposerDependencies(IS_NO_DEV) {
    echo 'Checking Composer dependency caches'
    script {
        if (IS_NO_DEV) {
            CACHE_DIRECTORY = 'composer-no-dev-cache'
            NO_DEV_OPTIONS = '--no-dev'
        } else {
            CACHE_DIRECTORY = 'composer-dev-cache'
            NO_DEV_OPTIONS = ''
        }
    }

    checkDependencyCacheOrInstall(
        'composer.lock',
        'vendor',
        "/var/lib/jenkins/project-files/$PROJECT_NAME/$CACHE_DIRECTORY",
        "composer install --no-interaction --no-autoloader --no-progress $NO_DEV_OPTIONS",
        'composer audit',
        "composer dump-autoload --no-interaction --classmap-authoritative --strict-psr --strict-ambiguous $NO_DEV_OPTIONS"
    )
}

def getNodeDependencies() {
    echo 'Checking Node dependency caches'
    checkDependencyCacheOrInstall(
        'package-lock.json',
        'node_modules',
        "/var/lib/jenkins/project-files/$PROJECT_NAME/node-cache",
        'npm ci --audit',
        '',
        ''
    )
}

def checkDependencyCacheOrInstall(DEPENDENCY_LOCKFILE, DEPENDENCY_DIRECTORY, CACHE_PATH, INSTALL_COMMAND, AUDIT_COMMAND, AUTOLOADER_COMMAND) {
    sh """#!/bin/bash
        
        # TODO: re-enable this, once audit failure handling is implemented
        # set -eu

        CACHE_HIT=false

        # check existing caches
        if [ -d $CACHE_PATH ] && [ ! -z "\$(ls $CACHE_PATH)" ]; then
            for DIRECTORY in $CACHE_PATH/*/; do
                # cache hit
                if cmp -s $DEPENDENCY_LOCKFILE "\$DIRECTORY/$DEPENDENCY_LOCKFILE"; then
                    echo "Cache hit: \$DIRECTORY";
                    cp -r "\$DIRECTORY/$DEPENDENCY_DIRECTORY" .
                    $AUDIT_COMMAND
                    $AUTOLOADER_COMMAND
                    CACHE_HIT=true
                    break
                fi
            done
        fi

        # if no cache hits, install dependencies and save cache
        if ! \$CACHE_HIT; then
            echo 'No cache hits. Downloading dependencies and creating new cache'
            $INSTALL_COMMAND
            $AUDIT_COMMAND

            #create cache
            CACHE_SAVE_PATH=$CACHE_PATH/\$(date '+%Y-%m-%d_%H-%M-%S')
            mkdir -p \$CACHE_SAVE_PATH
            cp $DEPENDENCY_LOCKFILE \$CACHE_SAVE_PATH
            cp -r $DEPENDENCY_DIRECTORY \$CACHE_SAVE_PATH

            # delete excess caches
            if [ \$(ls $CACHE_PATH | wc -l) -gt $DEPENDENCY_CACHES_TO_KEEP ]; then
                find $CACHE_PATH -mindepth 1 -maxdepth 1 -type d | sort | head -n -$DEPENDENCY_CACHES_TO_KEEP | xargs rm -rf
            fi

            $AUTOLOADER_COMMAND
        fi
    """
}
