# -*- coding: utf-8 -*-
class User < ActiveRecord::Base
  has_many :authentications, :dependent=>:destroy
  has_many :tweets, :dependent=>:destroy
  has_many :connections, :dependent=>:destroy
  has_many :friends, :through=>:connections, :source => :user

  # Include default devise modules. Others available are:
  # :token_authenticatable, :confirmable, :lockable and :timeoutable
  # , :registerable, recoverable, :rememberable
  devise :database_authenticatable, :rememberable, :trackable
#  devise :trackable, :validatable, :database_authenticatable, :registerable, :recoverable, :rememberable

  # Setup accessible (or protected) attributes for your model
  # :email, :password, :password_confirmation, :remember_me
  attr_accessible :email, :password, :password_confirmation, :remember_me,
  :nickname, :image_url

  validates_presence_of :nickname, :image_url

  def update_info(oa)
    update_attribute(:nickname,oa['user_info']['nickname'])
    update_attribute(:image_url,oa['user_info']['image'])
    Twitter.friend_ids(oa['user_info']['nickname'])["ids"].each do |id|
      if auth = Authentication.find_by_provider_and_uid(oa['provider'], id)
        friends << auth.user
      end
    end
  end
end
