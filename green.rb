#!/usr/bin/env ruby
require 'rubygems'
require 'json'
require 'sinatra/base'

require 'lib/green'

DataMapper.setup(:default, ENV['DATABASE_URL'] || "sqlite3://#{FileUtils.pwd}/green.db")

class Green < Sinatra::Default
  register Sinatra::Green::Controller

  set :views,  'views'
  set :public, 'public'
  set :environment, :production
  set :search_terms, ["綠壩", "绿坝", "greendam"]
  set :items_per_page, 25
end
