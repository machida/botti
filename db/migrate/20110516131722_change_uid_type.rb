class ChangeUidType < ActiveRecord::Migration
  def self.up
    remove_column :authentications, :uid
    add_column :authentications, :uid, :integer
  end

  def self.down
    remove_column :authentications, :uid
    add_column :authentications, :uid, :string
  end
end
