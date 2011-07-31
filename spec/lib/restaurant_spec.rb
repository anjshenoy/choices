require File.dirname(__FILE__) + "/../../lib/restaurant.rb"

describe Restaurant do

  let(:r) {Restaurant.new(1, 1.75, "fries")}
  context "initialization" do
    it "has an ID" do
      Restaurant.new(1, nil, nil).id.should == 1
    end

    it "has a list of single items with the price for each" do
      Restaurant.new(1, 2.00, "burger").single_items.should == {"burger" => 2.00}
    end


    it "has a list of value items with the price for each, with the sorted items strigified as a key" do
      Restaurant.new(1, 2.00, "burger", "fries", "drink").value_items.should == {"burger_drink_fries" => 2.00}
    end
  end

  context "adding more items" do
    let(:r) { Restaurant.new(1, 2.00, "burger")} 

    it "can take on more single items" do
      r.add_items(2.00, "fries")
      r.single_items.should == {"burger" => 2.00, "fries" => 2.00}
    end

    it "can take on more value items" do
      r.add_items(2.25, "burger", "fries")
      r.value_items.should == {"burger_fries" => 2.25}
    end

    it "can take on single and value items" do
      r.add_items(2.00, "fries")
      r.add_items(2.25, "burger", "fries")
      r.single_items.should == {"burger" => 2.00, "fries" => 2.00}
      r.value_items.should == {"burger_fries" => 2.25}
    end

    it "throws an error if no items are provided" do
      lambda{r.add_items(2.25)}.should raise_error(ArgumentError, "Data Error:: Item required in order to proceed")
    end
  end

  context "item check" do

    context "against single item list" do
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

    context "against both single and value item lists" do
      before(:each) do
        r.add_items(5.00, "burger", "shake")
      end

      it "returns true if the item exists in single or value item list" do
          r.has_items?("fries").should be_true
          r.has_items?("shake").should be_true
      end
      it "returns false if the item exists in neither the single or value item list" do
          r.has_items?("boo").should be_false
      end
      context "for multiple items" do
        it "returns true if the item combination exists in the value item list" do
          r.has_items?("burger", "shake").should be_true
        end
        it "returns true if the item combination exists in the single item list" do
          r.add_items(2.00, "shake")
          r.has_items?("fries", "shake").should be_true
        end
        it "returns true if the item combination exists in the single or value item list" do
          r.has_items?("fries", "shake").should be_true
        end
      end
    end
  end

  context "single item price combinations" do
    before(:each) do
      r.add_items(3.00, "burger")
    end
    it "generates all possible price combinations for single items" do
      r.single_item_combinations.should == {"fries"=>1.75, "burger"=>3.0, "burger_fries"=>4.75, "burger_fries" => 4.75}
    end
  end
end
