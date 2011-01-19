#!/usr/bin/env ruby

# require 'YAML' # becomes broken after requiring twitter.
# But twitter somehow loads YAML by itself so really not needed.
require 'plurk'
require 'twitter'

def hidden_gets # inspired by highline gem
  state = `stty -g`
  system "stty -echo"
  data = gets
  system "stty #{state}"
  puts
  data
end

Signal.trap("INT") do
  exit(0)
end

Signal.trap("TERM") do
  exit(0)
end

Signal.trap("KILL") do
  exit(0)
end

CONFIG_FILE = "#{ENV["HOME"]}/.plurked"
if File.exist?(CONFIG_FILE)
  config = YAML.load_file CONFIG_FILE
end
if config.nil?
  config={}
  print "Your Plurk API key (if no just press Enter): "
  config[:key]=gets.chomp
  if config[:key].empty?
    config[:key]="cSNVxXehxV1LuSraZl3D2lnqJnAuS52t"
  end
  print "Plurk login: "
  config[:username]=gets.chomp
  print "Plurk password: "
  config[:username]=gets.chomp
  print "Twitter login: "
  config[:twitter]=gets.chomp
  print "Update interval(sec): "
  config[:interval]=gets.to_i
  config[:lastcheck]=Time.now
end

plurk = Plurk::Client.new config[:key]

if !config[:password] || config[:password].empty?
  puts "Enter plurk password"
  pass = STDIN.gets.chomp
  config[:password] = pass
end

# does not work if put after 'require "twitter"'
begin
  plurk.login :username => config[:username], :password => config[:password]  
rescue Exception => e
  STDERR.puts "Exception #{e.inspect} on plurk authorization. \
Check your configuration file and internet connection."
  exit(2)
end

while(true)
  begin
    # puts "checking"
    new_tweets = Twitter.user_timeline(config[:twitter]).select{|t| Time.parse(t["created_at"]) > config[:lastcheck]}
    new_tweets.reverse.each do |tweet|
      plurk.plurk_add :content => tweet[:text], :qualifier => "tweets"
      # puts "plurked: "+ tweet.text
    end
    config[:lastcheck]=Time.now
    f = File.new(CONFIG_FILE,"w")
    f.write(YAML.dump(config))
    f.close
  rescue SystemExit, Interrupt
    exit(0)
  rescue Exception => e
    STDERR.puts "Got exception #{e.inspect}. Check your internet connection."
  ensure
    f = File.new(CONFIG_FILE,"w")
    f.write(YAML.dump(config))
    f.close
  end
  sleep(config[:interval])
end
