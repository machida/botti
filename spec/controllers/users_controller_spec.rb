require 'spec_helper'

describe UsersController do
  before { @u = login_user }

  describe "GET 'show'" do
    it "should be successful" do
      get 'show', :id=>@u.id
      response.should be_success
    end

    it "should redirect when he is not the owner" do
      get 'show', :id=>User.make.id
      response.should be_redirect
      response.should redirect_to @u
    end
  end

  describe "GET 'map'" do
    it "should be rendered only with map.html" do
      get "map", :id=>@u.id
      response.should render_template "users/map"
      response.should_not render_template "layouts/application"
    end
  end
end
