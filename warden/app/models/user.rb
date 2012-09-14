class User < ActiveRecord::Base
  attr_accessible :password, :username

  def self.authenticate(username, password)
    u = self.find_by_username(username)
    return u if u && u.password == password
  end
end
