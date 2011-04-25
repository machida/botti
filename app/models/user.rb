class User < ActiveRecord::Base
  has_many :authentications, :dependent=>:destroy

  # Include default devise modules. Others available are:
  # :token_authenticatable, :confirmable, :lockable and :timeoutable
  # , :registerable, recoverable, :rememberable
  devise :database_authenticatable, :rememberable, :trackable
#  devise :trackable, :validatable, :database_authenticatable, :registerable, :recoverable, :rememberable

  # Setup accessible (or protected) attributes for your model
  # :email, :password, :password_confirmation, :remember_me
  attr_accessible :email, :password, :password_confirmation, :remember_me
end
