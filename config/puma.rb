#!/usr/bin/env puma

app_name = "OneLanguage"

environment ENV['RAILS_ENV'] || 'production'

daemonize true

pidfile "/var/www/#{app_name}/shared/tmp/pids/puma.pid"
stdout_redirect "/var/www/#{app_name}/shared/tmp/log/stdout", "/var/www/#{app_name}/shared/tmp/log/stderr"

threads 0, 16

bind "unix:///var/www/#{app_name}/shared/tmp/sockets/puma.sock"