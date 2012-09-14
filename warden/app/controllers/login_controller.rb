class LoginController < ApplicationController
  def login
    # Reset session
    env['warden'].logout
    if env['warden'].authenticate
      render :text => "success"
    else
      render :text => "failure"
    end
  end
end
