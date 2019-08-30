#!/bin/sh
cd ~/foreman
git fetch --all
git checkout develop
git reset --hard origin/develop

cd ~/katello
git fetch --all
git checkout master
git reset --hard origin/master

cd ~/foreman
scl enable rh-ruby25 -- bundle install
npm install
