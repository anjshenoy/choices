require File.dirname(__FILE__) + "/../../lib/restaurant"

describe Restaurant do

  context "initialization" do
    it "has an ID" do
      Restaurant.new(1, nil, nil).id.should == 1
    end

    it "has a list of single items with the price for each" do
      Restaurant.new(1, 2.00, "burger").line_items.should == {["burger"] => 2.00}
    end


    it "has a list of value items with the price for each, with the sorted items strigified as a key" do
      Restaurant.new(1, 2.00, "burger", "fries", "drink").line_items.should == {["burger", "drink", "fries"] => 2.00}
    end
  end

  context "adding more items" do
    let(:r) { Restaurant.new(1, 2.00, "burger")} 

    it "can take on more single items" do
      r.add_items(2.00, "fries")
      r.line_items.should == {["burger"] => 2.00, ["fries"] => 2.00}
    end

    it "can take on more value items" do
      r.add_items(2.25, "burger", "fries")
      r.line_items.should == {["burger"] => 2.00, ["burger", "fries"] => 2.25}
    end

    it "can take on single and value items" do
      r.add_items(2.00, "fries")
      r.add_items(2.25, "burger", "fries")
      r.line_items.should == {["burger"] => 2.00, ["fries"] => 2.00, ["burger", "fries"] => 2.25}
    end

    it "throws an error if no items are provided" do
      lambda{r.add_items(2.25)}.should raise_error(ArgumentError, "Data Error:: Item required in order to proceed")
    end
  end

  context "item check" do

    context "against single item list" do
      let(:r) {Restaurant.new(1, 1.75, "fries")}

      it "returns true if it has a particular item" do
        r.has_items?("fries").should be_true
      end

      it "returns true only if all supplied items exist in its menu" do
        r.has_items?("fries", "burger").should be_false
      end
    end
    context "against value items list" do
      let(:r) { Restaurant.new(1, 5, "burger", "fries", "drink") }
      it "returns true if it has a particular item" do
        r.has_items?("fries").should be_true
      end

      it "returns true if all supplied items exist in its menu" do
        r.has_items?("fries", "burger").should be_true
      end

      it "returns false if even one item out of the list of supplied items does not exist in its menu" do
        r.has_items?("fries", "burger", "boo").should be_false
      end

      it "returns true for multi-word items" do
        r.add_items(4.00, "burger", "fries", "coleslaw_with_sweet_mayo")
        r.has_items?("coleslaw_with_sweet_mayo").should be_true
      end
    end
  end

  context "price calculation" do
    let(:r) { Restaurant.new(1, 5.00, "burger", "fries", "drink") }

    it "returns nil if the order item does not exist in its menu" do
      r.price("boo").should be_nil
    end

#    context "first scans the menu to find the most relevant items to run against" do
#      it "finds the most relevant match for a single order item" do
#        r.price("fries").should == 5.00
#      end
#
#    end
  end
end
