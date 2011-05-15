require 'spec_helper'

describe UsersController do
  before { @u = login_user }

  describe "GET 'show'" do
    it "should be successful" do
      get 'show', :id=>@u.id
      response.should be_success
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
