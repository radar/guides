require 'spec_helper'

describe "Navigation" do
  include Capybara
  
  it "should be a valid app" do
    p Rails.application.routes
    ::Rails.application.should be_a(Dummy::Application)
  end
end
