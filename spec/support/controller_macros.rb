module ControllerMacros
  def login_user(status=nil)
    @u = User.make(status)
    sign_in :user, @u
    return @u
  end
end
