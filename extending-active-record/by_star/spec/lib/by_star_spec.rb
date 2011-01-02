require 'spec_helper'

describe "by_star" do
  context "by_year" do
    it "current year" do
      Post.by_year.map(&:text).should include("First post!")
    end
    
    it "a specified year" do
      Post.by_year(Time.now.year - 1).map(&:text).should include("So last year!")
    end
  end
  
end