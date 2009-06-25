path = File.expand_path(File.dirname(__FILE__))
$:.unshift(path) unless $:.include?(path)

gem 'datamapper', '>= 0.9.11'
gem 'data_objects', '>= 0.9.11'
require 'data_objects'
#gem 'do_postgres', '>= 0.9.11'
#require 'do_postgres'
require 'datamapper'
require 'green/model'
require 'green/controller'