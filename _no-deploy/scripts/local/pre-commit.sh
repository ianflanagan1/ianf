#!/bin/bash

./vendor/bin/pint --dirty -v
php artisan test --coverage --min=70
php artisan dusk