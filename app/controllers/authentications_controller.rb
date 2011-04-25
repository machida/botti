class AuthenticationsController < ApplicationController
  before_filter :authenticate_user!, :only=>[:index, :destroy]
  def index
    @authentications = current_user.authentications
  end

  def create
    oa = request.env["omniauth.auth"]
    authentication = Authentication.
      find_by_provider_and_uid(oa['provider'], oa['uid'])
    if authentication
      flash[:notice] = "既存アカウント。ログインしました"
      sign_in_and_redirect(:user, authentication.user)
      return
    else
      if current_user
        # TODO: あたらしい関連づけをあたえる
        flash[:notice] = "ログイン済み"
        redurect_to authentications_url
        return
      else
        flash[:notice] = "新規アカウント。ログインしました"
        user = User.new(:nickname=>oa['user_info']['nick_name'])
        user.authentications.build(:provider=>oa['provider'], :uid=>oa['uid'])
        user.save!
        sign_in_and_redirect(:user, user)
      end
    end
  end

  def destroy
    @authentication = current_user.authentications.find(params[:id])
    @authentication.destroy
    redirect_to authentications_url, :notice => "当該の認証は無効化されました。"
  end
end
