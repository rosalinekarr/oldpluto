class ConvertRedisKeys < ActiveRecord::Migration[5.0]
  def change
    $redis.keys.each do |tag|
      $redis.rename(tag, "tags:#{tag}:count")
    end
  end
end
