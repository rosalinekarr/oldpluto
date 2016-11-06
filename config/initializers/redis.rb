if Rails.env.test?
  $redis = MockRedis.new
else
  $redis = Redis.new(url: ENV['REDIS_URL'])
end
