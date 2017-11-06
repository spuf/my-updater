#!/bin/bash

CONF_DIR=$(dirname $(readlink $0 || $0))

NPM_LIST="$CONF_DIR/npm.txt"
GEM_LIST="$CONF_DIR/Gemfile"

NPM_UNINSTALL=$(npm -g ls --depth 0 --parseable | grep node_modules | xargs -I '{}' basename '{}' | fgrep -v -f $NPM_LIST)
NPM_INSTALL=$(cat $NPM_LIST)

rm -f "$GEM_LIST.lock"

set -ex

brew update
brew upgrade
brew cleanup -s
brew prune

[ -n "$NPM_UNINSTALL" ] && npm -g uninstall $NPM_UNINSTALL
npm install -g --loglevel error $NPM_INSTALL > /dev/null
npm update -g --loglevel error
#npm cache clean --force --loglevel error

yarn global upgrade
#yarn cache clean

brew link --overwrite ruby
gem update bundler
bundle install --system --clean --force --gemfile=$GEM_LIST --quiet
gem cleanup

vagrant plugin update || vagrant plugin expunge --reinstall
vagrant box list | awk '{ print $1 }' | xargs -I {} vagrant box update --box {} || true
vagrant box prune
vagrant version
