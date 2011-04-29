require File.dirname(__FILE__) + '/../spec_helper'

describe AuthenticationsController do
  fixtures :all
  render_views

  before do
    login_user
  end

  it "index action should render index template" do
    get :index
    response.should render_template(:index)
  end

  it "destroy action should destroy model and redirect to index action" do
    authentication = Authentication.first
    delete :destroy, :id => authentication
    response.should redirect_to(authentications_url)
    Authentication.exists?(authentication.id).should be_false
  end
end
