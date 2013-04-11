#require 'twitter'
require 'tweetstream'
require 'pp'
require 'awesome_print'
require 'json'
require 'net/http'
require 'optparse'
require 'optparse/time'
require './htmlcolors'
require 'color'
require 'color/css'

# This Twitter robot spies a given hashtag, and sends M3DA command to control an RGB LED strip
# depending on what happens on the twitter feed (color names tweeted, a specific user)

options = {}

OptionParser.new do |opts|
    opts.banner = "Usage: twitterbot.rb [options]"

    options[:twitter_secret] = nil
    opts.on( '-s', '--secret SECRET', 'Twitter OAuth secret' ) do |s|
        options[:twitter_secret] = s
    end

    options[:beginning] = Time.new
    opts.on( '-b', '--begin [TIME]', Time, 'Time when starting the twitter lookup' ) do |t|
        options[:beginning] = t
    end

    # This displays the help screen, all programs are
    # assumed to have this option.
    opts.on( '-h', '--help', 'Display this screen' ) do
        puts opts
        exit
    end
end.parse!

if options[:twitter_secret] == nil
    puts "You must indicate your secret OAuth token for twitter connection"
    exit
end

ap options

TweetStream.configure do |config|
    config.consumer_key = 'etm7StcMO7oGYZPeMNM0A'
    config.consumer_secret = 'RjL9DrdQIs6RUBeucxU6n4frQtRBzKJM3QomzmsRM'
    config.oauth_token = '16058280-632B3BjBtEUIKcPnF182k8khIGhOwT7tcD9x9unN2'
    config.oauth_token_secret = options[:twitter_secret]
end


beginning = options[:beginning]
activityByMinute = Array.new(60, 0)

http = Net::HTTP.new("m2m.eclipse.org")



TweetStream::Client.new.track('kartben', 'jaxcon', 'jax', '#jaxcon', '#jax', 'color') do |status|
    #ap status
    ap status.text
    colorToPush = Color::CSS['DimGrey'] ; blink = false

    status.text.split.each do |w|
        #pp w
        if Color::CSS[w]
            colorToPush = Color::CSS[w]
        end
    end

    # if there is a @kartben mention...
    if !status.user_mentions.empty? and status.user_mentions[0].screen_name == 'kartben'
        colorToPush = colorToPush or Color::CSS['white']
        blink = true
    end

    if colorToPush then
        ap colorToPush
        settings = { :settings => [ { :key => "leds.pushPixel", :value => { :red => colorToPush.red, :blue => colorToPush.blue, :green => colorToPush.green, :blink => blink } } ] }
        #ap settings
        request = Net::HTTP::Post.new("/m3da/data/jaxcon-demo")
        request.body = settings.to_json
        response = http.request(request)
    end 
end




    # s = 0
    # while true
    #   search = Twitter.search("eclipse", :count => 100, :result_type => "recent", :since_id => s)
    #   #ap search.results
    #   s = search.max_id
    #   search.results.reverse.each do |status|
    #       if status.created_at > beginning
    #           puts "#{status.text}, by #{status.user.screen_name} at #{status.created_at}" "\n" "\n"
    #           theMinute = (status.created_at - beginning.to_f).to_i / 30
    #           activityByMinute[theMinute] += 1
    #       end
    #   end
    #   ap activityByMinute

    #   settings = { :settings => [ { :key => "leds.colors", :value => activityByMinute } ] }
    #   request = Net::HTTP::Post.new("/m3da/data/jaxcon-demo")
    #   request.body = settings.to_json
    #   response = http.request(request)

    #   sleep 5
    # end




