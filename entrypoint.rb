#!/usr/bin/env ruby

ROOT_DIR = "/root"
RUBY_SCL = "scl enable rh-ruby25 --"

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
  `#{RUBY_SCL} bundle install --jobs=5 `

  STDOUT.puts "Installing node packages"
  `npm install`

  STDOUT.puts "Setting up db"
  `#{RUBY_SCL} bundle exec rake db:drop || true`
  `#{RUBY_SCL} bundle exec rake db:create --trace`
  `#{RUBY_SCL} bundle exec rake db:migrate`

  STDOUT.puts "Starting server"
  `#{RUBY_SCL} bundle exec foreman start`
end
