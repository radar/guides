require 'foodie/food'

describe Foodie::Food do
  it "broccoli is gross" do
    Foodie::Food.portray("Broccoli").should eql("Gross!")
  end
  
  it "anything else is delicious" do
    Foodie::Food.portray("Not Broccoli").should eql("Delicious!")
  end
  
  it "pluralizes a word" do
    Foodie::Food.pluralize("Tomato").should eql("Tomatoes")
  end
end