require "net/https"
require "yaml"
require "cgi"

require "rubygems"
require "json"
require "twitter_oauth"
require "oauth"


query = ARGV.shift
raise "please give some query" if query.nil?

env = YAML.load_file(File.dirname(__FILE__)+'/config.yml')

client = TwitterOAuth::Client.new(
                                  :consumer_key => env['CONSUMER_KEY'],
                                  :consumer_secret => env['CONSUMER_SECRET'],
                                  :token => env['ACCESS_TOKEN'],
                                  :secret => env['ACCESS_TOKEN_SECRET']
                                  )

consumer = OAuth::Consumer.new(
                               env['CONSUMER_KEY'], 
                               env['CONSUMER_SECRET'], 
                               :site => 'http://twitter.com'
                               )

access_token = OAuth::AccessToken.new(
                                      consumer, 
                                      env['ACCESS_TOKEN'], 
                                      env['ACCESS_TOKEN_SECRET']
                                      )

uri = URI.parse("https://userstream.twitter.com/2/user.json")

https = Net::HTTP.new(uri.host, uri.port)
https.use_ssl = true
https.verify_mode = OpenSSL::SSL::VERIFY_NONE

https.start do |https|
  request = Net::HTTP::Get.new(uri.request_uri)
  request.oauth!(https, consumer, access_token) 
  buf = ""
  https.request(request) do |response|
    response.read_body do |chunk|
      buf << chunk

      while (line = buf[/.+?(\r\n)+/m]) != nil
        begin
          buf.sub!(line,"")
          line.strip!
          status = JSON.parse(line)
        rescue
          break 
        end

        status
        if status['text']
          user = status['user']

          if user['screen_name'] == query
            client.favorite(status['id'])
            client.update("Favorite!! at {Time.now}")
            puts "Fav => #{user['screen_name']}:#{status['text']}"
          else
            puts "#{user['screen_name']}:#{status['text']}"
          end
        end
      end
    end
  end
end

