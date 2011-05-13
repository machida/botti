require 'spec_helper'

describe UsersController do

  describe "GET 'show'" do
    it "should be successful" do
      @u = login_user
      get 'show', :id=>@u.id
      response.should be_success
    end
  end

  describe "POST 'create'" do
    # it "invalid" do
    #   User.any_instance.stubs(:valid?).returns(false)
    #   post :create
    #   User.count.should == 0
    #   User.any_instance.stubs(:valid?).returns(true)
    # end

    it "valid" do
#      User.any_instance.stubs(:valid?).returns(true)
      User.count.should == 0
      post :create
      User.count.should == 0
    end
  end

end
