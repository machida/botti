class AddTweetIdToLocations < ActiveRecord::Migration
  def self.up
    add_column :locations, :tweet_id, :integer
  end

  def self.down
    remove_column :locations, :tweet_id
  end
end
