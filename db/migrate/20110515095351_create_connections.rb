class CreateConnections < ActiveRecord::Migration
  def self.up
    create_table :connections do |t|
      t.integer :user_id, :friend_id
      t.timestamps
    end
  end

  def self.down
    drop_table :connections
  end
end
