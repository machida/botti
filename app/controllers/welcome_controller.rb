class WelcomeController < ApplicationController
  def index
  end

  def about
  end

  def create # temporary post method
    auth = current_user.authentications.find_by_provider("twitter")
    if auth
      Twitter.configure do |config|
        config.consumer_key = 'TODO'
        config.consumer_secret = 'TODO'
## get when user activates
        config.oauth_token = auth.token
        config.oauth_token_secret = auth.secret
      end
      Twitter.update(params[:content])
      flash[:notice] = "投稿成功"
    else
      flash[:notice] = "関連づけられた twitter アカウントが見つかりませんでした。"
    end
    redirect_to root_path
  end

end
