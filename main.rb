#!/usr/bin/env ruby
require "rubygems"
require "pit"
require "thread"
require "xmpp4r-simple"
require "net/http"
require "json"
require "uri"
require "stream"
require "oauth"

$KCODE = "u"

twitter_q = Queue.new
post_q = Queue.new

config = Pit.get("im.twitter", :require => {
  "username" => "you email in twitter",
  "password" => "your password in twitter",
  "oauth_key" => "OAuth Key",
  "oauth_secret" => "OAuth Secret",
  "poster" => "IM Deliverier GTalk Mail Address",
  "poster_pass" => "IM Del Deliverier GTalk Password",
  "getter" => "IM Getter GTalk Mail Address"
})
im = Jabber::Simple.new config["poster"], config["poster_pass"]
p "Connected"
im.deliver "ssig33@gmail.com", "Start Twitter Streaming"
receive= Thread.fork do
  loop do
    im.received_messages do |msg|
      post_twitter msg.body.to_s, config
    end
    sleep 1
  end
end

get_twitter = Thread.fork do
  get_twitter_stream config, twitter_q
end

deliver_twitter = Thread.fork do
  while r = twitter_q.pop
    begin
      im.deliver config["getter"], "<@#{r["user"]["screen_name"]}> #{r["text"]}"
    rescue => e
      p e
    end
  end
end

receive.join
