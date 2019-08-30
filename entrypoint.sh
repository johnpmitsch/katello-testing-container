#!/bin/sh
cd /root/foreman
git fetch --all
git checkout develop
git reset --hard origin/develop

cd /root/katello
git fetch --all
git checkout master
git reset --hard origin/master

cd /root/foreman
scl enable rh-ruby25 -- bundle install
npm install
scl enable rh-ruby25 -- bundle exec foreman start
