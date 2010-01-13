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
  set :search_terms, ["stopxrl", "高鐵"]
  set :items_per_page, 25
end
