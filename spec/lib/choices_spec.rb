require File.dirname(__FILE__) + "/../../lib/restaurant"
require File.dirname(__FILE__) + "/../../lib/choices"

describe Choices do

  let(:choices) {Choices.new(1, 3.00, "burger")}

  context "initialization" do
    it "creates a list of restaurants, each with a menu" do
      restaurants = Choices.new(1, 3.00, "burger").restaurants
      restaurants.size.should == 1
      restaurants.values.first.id.should == 1
      restaurants.values.first.line_items.should == {["burger"] => 3.00}
    end
  end

  context "add_items to one or more restaurants" do
    it "can add any number of prices and menu items to each restaurant" do
      choices.add_items(1, 2.00, "shake")
      restaurants = choices.restaurants
      restaurants.size.should == 1
      restaurants.values.first.id.should == 1
      restaurants.values.first.line_items.should == {["burger"] => 3.00, ["shake"] => 2.00}
    end

    it "can add items when the restaurant is new i.e. not already existing in the list" do
      choices.add_items(2, 2.00, "shake")
      restaurants = choices.restaurants
      restaurants.size.should == 2
      restaurants.values.first.id.should == 1
      restaurants.values.first.line_items.should == {["burger"] => 3.00}
      restaurants.values.last.id.should == 2
      restaurants.values.last.line_items.should == {["shake"] => 2.00}
    end

    context "set up a restaurant with multiple single/value item menu options" do
      it "can add single/value items for one restaurant" do
        choices.add_items(1, 1.50, "fries")
        choices.add_items(1, 2.00, "shake")
        choices.add_items(1, 4.25, "burger", "fries")
        choices.add_items(1, 3.25, "shake", "fries")
        choices.restaurants.values.first.line_items.should == {["burger"] => 3.00, 
                                                               ["fries"] => 1.50, 
                                                               ["shake"] => 2.00, 
                                                               ["burger", "fries"] => 4.25, 
                                                               ["fries", "shake"] => 3.25}
      end

      it "can add single/value items for multiple restaurants" do
        choices.add_items(1, 1.50, "fries")
        choices.add_items(2, 2.00, "shake")
        choices.add_items(2, 4.25, "burger", "fries")
        choices.add_items(1, 3.25, "shake", "fries")
        choices.restaurants.values.first.line_items.should == {["burger"] => 3.00, ["fries"] => 1.50, ["fries", "shake"] => 3.25}
        choices.restaurants.values.last.line_items.should == {["shake"] => 2.00, ["burger", "fries"] => 4.25}
      end
    end
  end

  # no matches
  # multiple restaurants with the lowest price
  context "price calculator - given a set of restaurants with single/value items" do
    before(:each) do
      choices.add_items(1, 1.50, "fries")
      choices.add_items(1, 3.25, "shake", "fries")
      choices.add_items(2, 2.00, "fries")
      choices.add_items(2, 4.25, "burger", "fries")
    end

    it "finds the most optimal price given a single item " do
      choices.best_match("burger").should == "1, 3.0"
    end

    it "finds the most optimal price given a single item even if it exists as part of a value item menu" do
      choices.add_items(3, 6.00, "burger", "shake", "fries")
      choices.best_match("fries").should == "1, 1.5"
    end

    it "finds the most optimal price given multiple items" do
      choices.best_match("burger", "fries").should == "2, 4.25"
    end

    it "finds the most optimal price given single and value items" do
      choices.add_items(3, 2.50, "burger")
      choices.add_items(3, 6.00, "burger", "shake", "fries")
      choices.best_match("burger", "shake", "fries").should == "3, 6.0"
    end
  end

end
