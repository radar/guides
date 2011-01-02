class Post < ActiveRecord::Base

end

class Event < ActiveRecord::Base
  by_star do
    field :date
  end
end