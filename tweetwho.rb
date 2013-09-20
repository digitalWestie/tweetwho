#!/usr/bin/env ruby
require 'rubygems'
require 'serialport'
require 'twitter'
require 'colorize'

def median(array)
  sorted = array.sort
  len = sorted.length
  return (sorted[(len - 1) / 2] + sorted[len / 2]) / 2.0
end

if ARGV.size < 1
  STDERR.print <<EOF
  Usage: #{$0} serial_port
EOF
  exit(1)
end

sp = SerialPort.new(ARGV[0], 9600, 8, 1, SerialPort::NONE)

Twitter.configure do |config|
  config.consumer_key = "" #yall gotta get this yourself
  config.consumer_secret = ""
  config.connection_options = Twitter::Default::CONNECTION_OPTIONS.merge(:request => { 
    :open_timeout => 20,
    :timeout => 30
  })
end

reading = 0
ranges = [0..128,  128..256, 256..384, 384..512, 512..640, 640..768, 768..896, 896..1024]

users  = ["@digitalWestie", "@synchq", "@richquick", "@devonwalshe", "@praymurray", "@redjotter", "@ErinMcElhinney", "@1414grfx"]
username = users.first
replier = users.last
# recieve part
readingComplete = false;
reading = "";
range_index = 0;

=begin
  Thread.new do
    while TRUE do
      while (i = sp.gets) do
        puts i 
        reading = i;
        #readingComplete = i.include? "|"
      end
    end
  end
=end


puts "|"
sleep(0.2)
puts "|##"
sleep(0.2)
puts "|####"
sleep(0.2)
puts "|######"
sleep(0.2)
puts "|########"
sleep(0.2)
puts "|##########"
sleep(0.2)
puts "|############"
sleep(0.2)
puts "|##############"
sleep(0.2)
puts "|################"
sleep(0.2)
puts "|##################"
sleep(0.2)
puts "|####################"
sleep(0.2)
puts "|######################"

sp.print "let's go\n".encode("ASCII-8BIT") #STDIN.gets#.chomp  

while TRUE do   
  begin
    puts "\n\n\n\n\n\n"
                                                                         
    puts  "\n\n -------------- HELLO #CHSCOT -------------- \n\n".green
    sleep(1.5)
    puts "\n\n\n\n\n\n"
    sleep(1.5)
    puts "\n\n -------------- Shall we check out some tweets? -------------- \n\n".green
    sleep(1.5)
    puts "\n\n\n\n\n\n"
    puts "\n\n -------------- I'm gonna take some readings from the arduino now... -------------- \n\n"
    sleep(1.5)
    puts "\n\n\n\n\n\n"

    readings = []
    until (readings.length == 4) do
      serial_in = sp.gets 
      unless serial_in.nil? or serial_in.length == 0
        readings << serial_in.chomp.to_i
        puts "-------------->  Reading #{readings.length}: " + readings.last.to_s
      end
      sleep 0.03
    end

    sleep(1.5)
    puts "\n\n\n\n\n\n"

    reading = median(readings)#readings.inject{ |sum, el| sum + el }.to_f / readings.size # get average   
    puts "The median reading is : #{reading}"
    sleep(1.5)
    puts "\n\n\n\n\n\n"
    ranges.each_with_index { |r,i| range_index = i if r.cover? reading }  # get username 
    binary_str = range_index.to_s(2)

    puts "Binary seq: " + binary_str
    
    sleep(1.5)
    puts "\n\n\n\n\n\n"

    username_set = false
    binary_str.split("").each_with_index do |e,i|
      
      if i == 0 and !username_set and e == "1"
        username = users[0]
        replier = users[1]
        username_set = true
        break
      end

      if e.eql?("1") and !username_set
        username = users[i] 
        
        username_set = true
      elsif e.eql?("1")
        replier = users[i]         
        break
      end

    end

=begin    
    if reading >= 0 and reading <= 10
      username = "@synchq"
      replier = "@digitalWestie"
    elsif reading >= 60 and reading <= 69 
      username = "@synchq"
      replier = "@devonwalshe"
    elsif reading >= 30 and reading <= 36
      username = "@synchq"
      replier = "@redjotter"
    end
=end

    puts "      Searching for tweets to the user #{username}"
    sleep(1.5)
    puts "\n\n\n\n\n\n"
    puts "      from someone with the user name  #{replier}"
    sleep(1.5)
    puts "\n\n\n\n\n\n"
    
    begin
      #puts "last reading: #{reading}\n searching for: #{username} from #{replier}"
      r = Twitter.search(username, :count => 90)
      tweets = []
      r.statuses.each { |tweet| tweets << tweet.text if "@#{tweet.user.user_name}".eql?(replier) }
      if tweets.empty?
        puts "----------------- couldn't find any tweets from #{replier} to #{username}\n\n\n" 
        sleep(0.8)
        replier = (users - [username, replier]).sample
        puts "----------------- let's try from #{replier} to #{username}\n\n\n" 
        r.statuses.each { |tweet| tweets << tweet.text if "@#{tweet.user.user_name}".eql?(replier) }
      end
    rescue
      tweets = []
    end

    unless tweets.empty? 
      i = 0 
      for tweet in tweets
        messages = (tweet.length / 35.0).ceil 
        messages.times do |m|
          tweet_text = tweet[(m*35)..((m+1)*35-1)]
          sp.print (tweet_text + "\n").encode("ASCII-8BIT")
          puts "#{tweet_text}"
          sleep (0.6 * tweet_text.length)
        end
        if i > 4
          break
          #choose another username ?
        end
        
        sleep(1.5)
        puts "\n\n\n\n\n\n"
      end
    else
      puts "!!!!!!!!!!!!!!!!!!!!!    OH NOES!!! Twitter timed out - lets start again.\n !!!!!!!!1 \n\n\n\n"
      sp.print "Err: time out.\n".encode("ASCII-8BIT")
    end

  rescue Interrupt
    
    sp.close
    puts  #insert a newline character after ^C

  end

  sleep 1.0

end