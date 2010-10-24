class ForThem::ForumsController < ApplicationController
  def index
    @forums = ForThem::Forum.all
  end
end