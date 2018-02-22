Warden::Strategies.add(:password) do
  def valid?
    params["username"] || params["password"]
  end

  def authenticate!
    u = User.find_by(username: params["username"])
    u.try(:authenticate, params["password"]) ? success!(u) : fail!
  end
end
