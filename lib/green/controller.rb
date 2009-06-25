require 'sinatra/base'
$KCODE = 'UTF8'
require 'logger'
require 'httpclient'


module Sinatra
  module Green
    module Controller
      def self.registered(app)
        app.helpers Helpers

        app.before do
          @log = Logger.new($stdout)
          
          @client = HTTPClient.new
          begin
            tweet(options.search_terms.join(' OR '))
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
          last_tweet =  Tweet.first(:order => [:twitter_id.desc]).twitter_id rescue 0
          last_tweet ||= 0
          
          rpp = 100
          query = { 'q' => term, 'rpp' => rpp, 'since_id' => last_tweet }
          header = {'User-Agent' => 'greendam.heroku.com'}
          
          res = JSON.parse(@client.get_content("http://search.twitter.com/search.json", query, header))
          results = res['results']
          results.each do |t|
            #@log.info("tweet: #{t.inspect}")
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

        #Escape HTML
        def h(text)
          Rack::Utils.escape_html(text) 
        end
        
        #Rails style Partial
        def partial(template, *args)
          options = args.last.is_a?(Hash) ? args.last : {}
          
          options.merge!(:layout => false)
          if collection = options.delete(:collection) then
            collection.inject([]) do |buffer, member|
              buffer << erb(template, options.merge(
                                        :layout => false, 
                                        :locals => {template.to_sym => member}
                                      )
                           )
            end.join("\n")
          else
            erb template, options
          end
        end

        #prepare text for html output
        # add a tag to link
        # link hashtag
        # link user
        def prep(text)
          text = text.gsub /(http[s]?:\/\/[^ \t]+)[ \t]?/, "<a target=\"_BLANK\" href=\"\\1\">\\1</a> "
          text = text.gsub /#([^ \t]+)[ \t]?/, "<a target=\"_BLANK\" href=\"http://search.twitter.com/search?tag=\\1\">#\\1</a> "
          text = text.gsub /@([^ \t]+)[ \t]?/, "<a target=\"_BLANK\" href=\"http://twitter.com/\\1\">@\\1</a> "
        end 
      end
    end

  end
end