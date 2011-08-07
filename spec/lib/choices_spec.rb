require File.dirname(__FILE__) + "/../../lib/restaurant"
require File.dirname(__FILE__) + "/../../lib/choices"

describe Choices do

  let(:choices) {Choices.new(File.dirname(__FILE__) + "/../config/dataset.csv")}

  context "initialization" do
    let(:path) {"path/to/file"}
    let(:iostream) {stub("iostream")}

    before(:each) do
      iostream.stub(:each_line).and_yield("1, 2.00, fries\n")
    end

    it "loads the restaurant dataset from a file given a path to the file" do
      File.should_receive(:open).and_return(iostream)
      Choices.new(path)
    end

    it "loads each line of the file into a datastructure called restaurants, indexed by id" do
      choices.restaurants.keys.should == [1]
    end

    it "propagates the Data Error from the Restaurant classs if any input item is incorrect" do
      iostream_error = stub("iostream_error")
      iostream_error.stub(:each_line).and_yield("1, 2.00, \n")
      File.stub(:open).and_return(iostream_error)
      lambda { Choices.new(path)}.should raise_error(ArgumentError)
    end

    it "removes the \\n (if it exists) from each line read from disk" do
      File.stub(:open).and_return(iostream)
      Choices.new(path).restaurants[1].line_items.first.first.last.end_with?("\n").should_not be_true
    end

    it "processes the data for each new line" do
      File.stub(:open).and_return(iostream)
      restaurants = Choices.new(path).restaurants
      restaurants.size.should == 1
      first_restaurant = restaurants.values.first
      first_restaurant.id.should == 1
      first_restaurant.line_items.should == {["fries"] => 2.00}
    end
  end

  context "add_items to one or more restaurants" do
    it "can add any number of menu items to a restaurant" do
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
      it "can add menu items for one restaurant" do
        choices.add_items(1, 1.50, "fries")
        choices.add_items(1, 4.25, "burger", "fries")
        choices.restaurants.values.first.line_items.should == {["burger"] => 3.00, 
                                                               ["fries"] => 1.50, 
                                                               ["burger", "fries"] => 4.25}
      end

      it "can add menu items for multiple restaurants" do
        choices.add_items(1, 1.50, "fries")
        choices.add_items(2, 2.00, "shake")
        choices.add_items(2, 4.25, "burger", "fries")
        choices.add_items(1, 3.25, "shake", "fries")
        choices.restaurants.values.first.line_items.should == {["burger"] => 3.00, ["fries"] => 1.50, ["fries", "shake"] => 3.25}
        choices.restaurants.values.last.line_items.should == {["shake"] => 2.00, ["burger", "fries"] => 4.25}
      end
    end
  end

  context "find the best price across multiple restaurants with multiple menu items each" do
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

    it "returns a nice error message if there's no match" do
      choices.best_match("boo").should == "Sorry, no match found for boo"
    end
  end
end
