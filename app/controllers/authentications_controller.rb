# -*- coding: utf-8 -*-
class AuthenticationsController < ApplicationController
  before_filter :authenticate_user!, :only=>[:index, :destroy]
  def create
    oa = request.env["omniauth.auth"]

    # closed beta filter
    require "auth_info" unless ENV['CLOSE_FILTER'] == "false"
    unless ENV['CLOSE_FILTER'] == "false"
      require "filter"
      unless WHITELIST.include? oa['user_info']['nickname']
        redirect_to root_path, :alert => "もうしわけありません。現在ベータテスト中につき、ログインできません。試用してみたい場合は@tomy_kairaまでご連絡ください。"
        return # reject
      end
    end

    authentication = Authentication.
      find_by_provider_and_uid(oa['provider'], oa['uid'])
    if authentication
      flash[:notice] = "既存アカウント。ログインしました"
      authentication.user.update_info(oa)
      sign_in_and_redirect(:user, authentication.user)
      return
    else
      if current_user
        # TODO: 別のアカウントとの関連づけをあたえる
        flash[:notice] = "ログイン済み"
        redirect_to authentications_url
        return
      else
        flash[:notice] = "新規アカウント。ログインしました"
        user = User.new(:nickname=>oa['user_info']['nickname'])
        user.update_info(oa)
        user.authentications.build(:provider=>oa['provider'],
                             :uid=>oa['uid'],
                             :token=>oa['credentials']['token'],
                             :secret=>oa['credentials']['secret'])
        user.save!
        sign_in_and_redirect(:user, user)
      end
    end
  end
end
