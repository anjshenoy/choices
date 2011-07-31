require File.dirname(__FILE__) + "/../../lib/restaurant.rb"

describe Restaurant do

  let(:r) {Restaurant.new(1, 1.75, :fries)}
  context "initialization" do
    it "has an ID" do
      Restaurant.new(1, nil, nil).id.should == 1
    end

    it "has a list of single items with the price for each" do
      Restaurant.new(1, 2.00, :burger).single_items.should == {:burger => 2.00}
    end


    it "has a list of value items with the price for each" do
      Restaurant.new(1, 2.00, :burger, :fries, :drink).value_items.should == {[:burger, :fries, :drink] => 2.00}
    end
  end

  context "adding more items" do
    let(:r) { Restaurant.new(1, 2.00, :burger)} 

    it "can take on more single items" do
      r.add_items(2.00, :fries)
      r.single_items.should == {burger: 2.00, fries: 2.00}
    end

    it "can take on more value items" do
      r.add_items(2.25, :burger, :fries)
      r.value_items.should == {[:burger, :fries] => 2.25}
    end

    it "can take on single and value items" do
      r.add_items(2.00, :fries)
      r.add_items(2.25, :burger, :fries)
      r.single_items.should == {burger: 2.00, fries: 2.00}
      r.value_items.should == {[:burger, :fries] => 2.25}
    end

    it "throws an error if no items are provided" do
      lambda{r.add_items(2.25)}.should raise_error(ArgumentError, "Data Error:: Item required in order to proceed")
    end
  end

  it "generates a list of every single unique item on the menu with no prices" do
    r.add_items(2.00, :burger)
    r.add_items(3.50, :burger, :fries)
    r.add_items(1.00, :drink)
    r.add_items(5.00, :fajitas, :drink, :fries)
    r.all_items.should == {:fries => nil, :burger =>nil, :drink => nil, :fajitas => nil}
  end

  context "item check" do
    it "returns true if it has a particular item" do
      r.has_items?(:fries).should be_true
    end

    it "returns true only if all supplied items exist in its menu" do
      r.has_items?(:fries, :burger, :boo).should be_false
    end
  end

  context "price calculation algorithm" do
    it "first checks if it has the item" do
      r.should_receive(:has_item?).with(:fries).exactly(:once)
      r.price_for(:fries)
    end
  end

end
