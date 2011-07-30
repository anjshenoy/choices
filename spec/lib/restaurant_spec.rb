require File.dirname(__FILE__) + "/../../lib/restaurant.rb"

describe Restaurant do

  context "initialization" do
    it "has an ID" do
      Restaurant.new(1, nil, nil).id.should == 1
    end

    it "has a list of single items with the price for each" do
      Restaurant.new(1, 2.00, :burger).single_items.should == [{:burger => 2.00}]
    end


    it "has a list of value items with the price for each" do
      Restaurant.new(1, 2.00, :burger, :fries, :drink).value_items.should == [{[:burger, :fries, :drink] => 2.00}]
    end

    it "throws an error if no items are provided" do
      lambda{Restaurant.new(1, 2.00)}.should raise_error(ArgumentError, "Data Error:: Item required in order to proceed")
    end
  end

  context "adding more items" do
    let(:r) { Restaurant.new(1, 2.00, :burger)} 

    it "can take on more single items" do
      r.add_items(2.00, :fries).single_items.should == [{burger: 2.00}, {fries: 2.00}]
    end

    it "can take on more value items" do
      r.add_items(2.25, :burger, :fries).value_items.should == [{[:burger, :fries] => 2.25}]
    end
    it "can take on more value items" do
      lambda{r.add_items(2.25)}.should raise_error(ArgumentError, "Data Error:: Item required in order to proceed")
    end
  end
end
