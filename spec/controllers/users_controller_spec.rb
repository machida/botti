require 'spec_helper'

describe UsersController do
  before { @u = login_user }

  describe "GET 'show'" do
    it "should be successful" do
      get 'show', :id=>@u.id
      response.should be_success
    end
  end
end
