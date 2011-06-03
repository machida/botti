require 'auth_info'
print "heroku config:add "
%w[CONSUMER_KEY CONSUMER_SECRET TWITTER_SUFFIX MESSAGE_SUFFIX].each do |k|
  print "#{k}=\"#{ENV[k]}\" "
end
puts
