#!/usr/bin/env ruby

# require 'YAML' # becomes broken after requiring twitter.
# But twitter somehow loads YAML by itself so really not needed.
LOCK_FILE = ENV["HOME"]+"/.plurked_lock"
if File.exist?(LOCK_FILE)
  STDERR.puts "Already running. If not, please delete ~/.plurked_lock"
  exit(4) # not terminate() because terminate() deletes lock file. In further code terminate must be used.
else
  system "touch "+LOCK_FILE
end

require 'plurk'
require 'twitter'

def terminate(code)
  system "rm "+LOCK_FILE
  exit(code)
end

def hidden_gets # inspired by highline gem
  state = `stty -g`
  system "stty -echo"
  data = gets
  system "stty #{state}"
  puts
  data
end

Signal.trap("INT") do
  terminate(0)
end
Signal.trap("TERM") do
  terminate(0)
end
Signal.trap("KILL") do
  terminate(0)
end

CONFIG_FILE = "#{ENV["HOME"]}/.plurked"
if File.exist?(CONFIG_FILE)
  config = YAML.load_file CONFIG_FILE
end
# initial configuration
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
  print "Update interval(sec, recomended >60): "
  config[:interval]=gets.to_i
  if config[:interval]==0
    config[:interval]=60
  end
  config[:lastcheck]=Time.now
end

if ARGV.include? "-s" or ARGV.include? "--skip"
  # skip tweets posted before plurked startup
  config[:lastcheck]=Time.now
end

begin
  plurk = Plurk::Client.new config[:key]
  plurk.login :username => config[:username], :password => config[:password]
rescue Exception => e
  STDERR.puts "Exception #{e.inspect} on plurk authorization. \
Check your configuration file and internet connection."
  sleep(config[:interval])
  retry
end

while(true)
  begin
    new_tweets = Twitter.user_timeline(config[:twitter]).select do |t|
      Time.parse(t["created_at"]) > config[:lastcheck]
    end
    new_tweets.reverse.each do |tweet|
      plurk.plurk_add :content => tweet[:text] unless tweet[:text].start_with?("@")
    end
    config[:lastcheck]=Time.now
    f = File.new(CONFIG_FILE,"w")
    f.write(YAML.dump(config))
    f.close
  rescue SystemExit, Interrupt
    terminate(0)
  rescue Twitter::BadRequest
    puts "Twitter requests per hour limit exceeded. You need to increase poll \
interval in your ~/.plurked"
  rescue Exception => e
    STDERR.puts "Got exception #{e.inspect}. Check your internet connection."
  ensure
    f = File.new(CONFIG_FILE,"w")
    f.write(YAML.dump(config))
    f.close
  end
  sleep(config[:interval])
end
