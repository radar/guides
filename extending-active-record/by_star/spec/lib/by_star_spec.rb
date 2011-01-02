require 'spec_helper'

describe "by_star" do
  context "by_year" do
    it "current year" do
      Post.by_year.map(&:text).should include("First post!")
    end
    
    it "a specified year" do
      Post.by_year(Time.now.year - 1).map(&:text).should include("So last year!")
    end
    
    it "a specified year, with options" do
      published_posts = Post.by_year(Time.now.year, :field => "published_at")
      published_posts.map(&:text).should include("First published post!")
      published_posts.map(&:text).should_not include("First post!")
    end
    
    it "pre-configured field" do
      Event.by_year.map(&:name).should include("The Party")
    end
  end
  
end