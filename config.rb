require "rubygems"
require "oauth"

require "yaml"


CONSUMER_KEY        = 'zunjEJPm0CEaBXLaNQz3w'
CONSUMER_SECRET     = 'Zr93xOVZGszoTrgFrTT4SE5Jm2pi1zDrbPkFXVzHQNU'

consumer = OAuth::Consumer.new(
                               CONSUMER_KEY,
                               CONSUMER_SECRET,
                               :site => 'http://twitter.com'
                               )

request_token = consumer.get_request_token
system("firefox \"#{request_token.authorize_url}\"")

print "Input OAuth Verifier: "
oauth_verifier = gets.chomp.strip

access_token = request_token.get_access_token(
  :oauth_verifier => oauth_verifier
)

puts "Access token: #{access_token.token}"
puts "Access token secret: #{access_token.secret}"

config = Hash::new
config['CONSUMER_KEY']        = CONSUMER_KEY
config['CONSUMER_SECRET']     = CONSUMER_SECRET
config['ACCESS_TOKEN']        = access_token.token
config['ACCESS_TOKEN_SECRET'] = access_token.secret

open("config.yml","w") do |f|
  f.puts config.to_yaml
end

puts "Created config.yml!"
