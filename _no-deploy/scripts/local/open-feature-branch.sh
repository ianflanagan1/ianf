#!/bin/bash

FEATURE_NAME=$1

usage () {
    echo "Syntax: $(basename ${BASH_SOURCE[0]}) FEATURE_NAME"
}

# validate number of arguments
if [ $# -ne 1 ]; then
    echo "Error: requires 1 argument" 1>&2
    usage
    exit 1
fi

# validate FEATURE_NAME alphanumeric _ . -
if [[ ! "$FEATURE_NAME" =~ ^[a-zA-Z0-9_.-]+$ ]]; then
    echo "Error: FEATURE_NAME must be alphanumeric or _ . -" 1>&2
    usage
    exit 2
fi

git checkout develop
git pull
git checkout -b "feature/$FEATURE_NAME"
git push -u origin "feature/$FEATURE_NAME"