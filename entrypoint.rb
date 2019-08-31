#!/usr/bin/env ruby

ROOT_DIR = "/root"

Dir.chdir("#{ROOT_DIR}/foreman") do
  `git fetch --all`
  `git checkout develop`
  `git reset --hard origin/develop`
end

Dir.chdir("#{ROOT_DIR}/katello") do
  `git fetch --all`

  if ENV["KATELLO_PR"]
    `git fetch origin pull/#{ENV["KATELLO_PR"]}/head:pr#{ENV["KATELLO_PR"]}`
    `git checkout pr#{ENV["KATELLO_PR"]}`
  else
    `git checkout master`
    `git reset --hard origin/master`
  end
end

Dir.chdir("#{ROOT_DIR}/foreman") do
  STDOUT.puts "Installing gems"
  `scl enable rh-ruby25 -- bundle install`
  STDOUT.puts "Installing node packages"
  `npm install`
  `scl enable rh-ruby25 -- bundle exec rake db:migrate`
  `scl enable rh-ruby25 -- bundle exec foreman start`
end
