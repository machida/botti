require 'spec_helper'

describe UsersController do

  describe "GET 'show'" do
    it "should be successful" do
      @u = login_user
      get 'show', :id=>@u.id
      response.should be_success
    end
  end
end
