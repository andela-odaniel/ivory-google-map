#!/usr/bin/env bash

set -e

COMPOSER_PREFER_LOWEST=${COMPOSER_PREFER_LOWEST-false}
DOCKER_BUILD=${DOCKER_BUILD-false}

if [ "$DOCKER_BUILD" = true ]; then
    cp .env.dist .env

    docker-compose build
    docker-compose run --rm php composer update --prefer-source

    exit
fi

export DISPLAY=:99
/sbin/start-stop-daemon -Sbmq -p /tmp/xvfb_99.pid -x /usr/bin/Xvfb -- ${DISPLAY} -ac -screen 0, 1600x1200x24

curl http://selenium-release.storage.googleapis.com/2.48/selenium-server-standalone-2.48.0.jar > selenium.jar
curl http://chromedriver.storage.googleapis.com/2.12/chromedriver_linux64.zip > chromedriver.zip
unzip chromedriver.zip

java -jar selenium.jar -Dwebdriver.chrome.driver=./chromedriver > /dev/null 2>&1 &

composer self-update
composer remove --no-update --dev friendsofphp/php-cs-fixer

composer update --prefer-source `if [ "$COMPOSER_PREFER_LOWEST" = true ]; then echo "--prefer-lowest --prefer-stable"; fi`
