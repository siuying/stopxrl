require 'sinatra/base'
$KCODE = 'UTF8'
require 'logger'
require 'open-uri'

module Sinatra
  module Green
    module Controller
      def self.registered(app)
        app.helpers Helpers

        app.before do
          @log = Logger.new($stdout)
          begin
            options.search_terms.each do |term|
              tweet(term)
            end
          rescue StandardError => e
            @log.error "error loading tweet: #{e}"
          end
        end

        app.get '/' do
          @items = Tweet.all(:order => [:twitter_id.desc], :limit => 50)
          erb :index
        end

        app.error do
          "Opps! Something happened. Please report to me @<a href=\"http://twitter.com/siuying\">siuying</a>"
        end
      end
    
      module Helpers
        def tweet(term)
          last_tweet = Tweet.first(:order => [:twitter_id.desc]).twitter_id rescue 0
          last_tweet ||= 0
          
          rpp = 20
          
          res = JSON.parse(open("http://search.twitter.com/search.json?q=#{Rack::Utils.escape term}&rpp=#{rpp}&since_id=#{last_tweet}").read)
          results = res['results']
          results.each do |t|
            @log.info("tweet: #{t.inspect}")
            tweet = Tweet.first(:twitter_id => t['id'])
            if tweet.nil?
              Tweet.new(:from_user => t['from_user'], 
                :to_user => t['to_user'], 
                :created_at => t['created_at'], 
                :profile_image_url => t['profile_image_url'],
                :text => t['text'],
                :twitter_id => t['id']).save
            end
            tweet
          end
        end
        def h(text)
          Rack::Utils.escape_html(text) 
        end
      end
    end

  end
end