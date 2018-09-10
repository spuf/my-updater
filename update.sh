#!/bin/bash

# xcode-select --install

SOURCE="${BASH_SOURCE[0]}"
while [ -h "$SOURCE" ]; do
    DIR="$(cd -P "$(dirname "$SOURCE")" && pwd)"
    SOURCE="$(readlink "$SOURCE")"
    [[ $SOURCE != /* ]] && SOURCE="$DIR/$SOURCE"
done
CONF_DIR="$(cd -P "$(dirname "$SOURCE")" && pwd)"

NPM_LIST="$CONF_DIR/npm.txt"
GEM_LIST="$CONF_DIR/Gemfile"

NPM_INSTALL=$(cat $NPM_LIST)

rm -f "$GEM_LIST.lock"

set -ex

brew update
brew upgrade
brew cask upgrade
brew cleanup -s
brew prune

npm install -g --loglevel error $NPM_INSTALL > /dev/null
npm update -g --loglevel error
npm cache clean --force --loglevel error

yarn global upgrade
#yarn cache clean

gem update bundler
bundle install --system --clean --force --gemfile=$GEM_LIST --quiet
gem cleanup

vagrant plugin update || vagrant plugin expunge --reinstall
vagrant box list | awk '{ print $1 }' | xargs -I {} vagrant box update --box {} || true
vagrant box prune
