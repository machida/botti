require File.dirname(__FILE__) + '/../spec_helper'

describe TweetsController do
  render_views
  before do
    @u = login_user
  end

  it "new action should render new template" do
    get :new
    response.should render_template(:new)
  end

  it "create action should render new template when model is invalid" do
    Tweet.any_instance.stubs(:valid?).returns(false)
    post :create
    response.should render_template(:new)
  end

  it "create action should redirect when model is valid" do
    Tweet.any_instance.stubs(:valid?).returns(true)
    post :create, :tweet=>{:user_id=>@u.id}
    response.should redirect_to @u
  end
end
