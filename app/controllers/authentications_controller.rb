# -*- coding: utf-8 -*-
class AuthenticationsController < ApplicationController
  before_filter :authenticate_user!, :only=>[:index, :destroy]
  def create
    oa = request.env["omniauth.auth"]

    # closed beta filter
    unless ENV['RACK_ENV'] == "production"
      require "filter"
      unless WHITELIST.include? oa['user_info']['nickname']
        redirect_to root_path, :alert => "許可がないためログインできません。"
        return
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
        redirect_to user_path
        return
      else
        flash[:notice] = "新規アカウント。ログインしました"
        user = User.new(:nickname=>oa['user_info']['nickname'])
        user.authentications.build(:provider=>oa['provider'],
                             :uid=>oa['uid'],
                             :token=>oa['credentials']['token'],
                             :secret=>oa['credentials']['secret'])
        begin
          user.update_info(oa)
        rescue Twitter::Unauthorized
          redirect_to auth_failure_path, :alert => "認証に失敗しました。プライベートモードにしている場合、ご利用いただけない場合があります。"
          return
        end
        user.save!
        sign_in_and_redirect(:user, user)
      end
    end
  end
end
