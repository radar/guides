class LoginController < ApplicationController
  def login
    # Reset session
    warden.reset_session!
    user = warden.authenticate
    if user
      warden.set_user(user)
      redirect_to logged_in_path
    else
      render plain: "failure"
    end
  end

  def logged_in
    user = warden.user
    render plain: "You are logged in as #{user.username}"
  end

  private

  def warden
    request.env['warden']
  end
end
