#!/bin/bash

source "$(dirname "${BASH_SOURCE[0]}")/../../../_gitignore/project-config"

./vendor/bin/pint --dirty -v
php artisan test --coverage --min="$TEST_COVERAGE_LIMIT"
php artisan dusk