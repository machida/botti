class Authentication < ActiveRecord::Base
  belongs_to :user
  attr_accessible :user_id, :provider, :uid, :token, :secret

  validates_presence_of :provider, :uid, :token, :secret
end
