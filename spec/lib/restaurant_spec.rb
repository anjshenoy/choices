require File.dirname(__FILE__) + "/../../lib/restaurant"

describe Restaurant do

  context "initialization" do
    it "has an ID" do
      Restaurant.new(1, 2, nil).id.should == 1
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

    context "if prices or items are invalid" do
      it "throws an error if no items are provided" do
        lambda{r.add_items(2.25)}.should raise_error(ArgumentError, "Data Error:: Menu items are missing for Restaurant ID: #{r.id} and are required in order to proceed")
      end
      it "throws an error if the price cannot be converted to float" do
        lambda{r.add_items("asd", "fries")}.should raise_error(ArgumentError, "Data Error:: Price is invalid for restaurant ID:#{r.id} and is required in order to proceed")
      end
      it "throws an error if the restaurant id is 0 i.e. invalid" do
        lambda{Restaurant.new("boo", 2.0, "fries")}.should raise_error(ArgumentError, "Data Error:: Restaurant ID: boo is not acceptable. Please correct the data file")
      end
    end
  end

  context "item check" do

    context "against single item list" do
      let(:r) {Restaurant.new(1, 1.75, "fries")}

      it "returns true if it has a particular item" do
        r.has_items?(["fries"]).should be_true
      end

      it "returns true only if all supplied items exist in its menu" do
        r.has_items?(["fries", "burger"]).should be_false
      end
    end
    context "against value items list" do
      let(:r) { Restaurant.new(1, 5, "burger", "fries", "drink") }
      it "returns true if it has a particular item" do
        r.has_items?(["fries"]).should be_true
      end

      it "returns true if all supplied items exist in its menu" do
        r.has_items?(["fries", "burger"]).should be_true
      end

      it "returns false if even one item out of the list of supplied items does not exist in its menu" do
        r.has_items?(["fries", "burger", "boo"]).should be_false
      end

      it "returns true for multi-word items" do
        r.add_items(4.00, "burger", "fries", "coleslaw_with_sweet_mayo")
        r.has_items?(["coleslaw_with_sweet_mayo"]).should be_true
      end

      it "returns true if the item is listed more than once" do
        r.has_items?(["fries"]*2).should be_true
      end
      it "returns true if a combination of items is listed more than once" do
        r.has_items?(["burger"] + ["fries"]*2).should be_true
      end
    end
  end

  context "price calculation" do
    let(:r) { Restaurant.new(1, 5.00, "burger", "fries", "drink") }

    it "returns nil if the order item does not exist in its menu" do
      r.price(["boo"]).should be_nil
    end

    context "if an exact match is found" do
      it "returns the price right away" do
        r.price(["burger", "fries", "drink"]).should == 5.00
      end
      it "does not look for the best price by searching through menu item combinations" do
        r.should_not_receive(:find_best_price)
        r.price(["burger", "fries", "drink"])
      end
    end

    context "if an exact match is not found" do
      let(:r) { Restaurant.new(1, 5.00, "burger", "fries", "drink") }
      before(:each) do
        r.add_items(5.00, "bourbon")
        r.add_items(2.00, "soda")
        r.add_items(3.00, "burger", "fries")
      end
      it "a set of items that have at least one menu element in common between menu items and order items" do
        r.should_receive(:relevant_matches).
          with(r.line_items.to_a, ["burger"]).
          and_return([[["burger", "fries"], 3.00]])
        r.price(["burger"])
      end

      context "always find the lowest price" do
        it "for a single item" do
          r.price(["soda"]).should == 2.00
        end
        it "for multiple single items" do
          r.price(["soda", "bourbon"]).should == 7.00
        end
        context "for multiple items" do
          it "when the items are included in a single value menu" do
            r.price(["burger", "fries"]).should == 3.00
          end
          it "when the items are included as part of multiple value menus" do
            r.add_items(5.00, "fajitas", "salsa")
            r.price(["burger", "fries", "fajitas", "salsa"]).should == 8.00
          end
          it "when the items are included as part of multiple single and value menus" do
            r.add_items(5.00, "fajitas", "salsa")
            r.add_items(2.00, "salsa")
            r.add_items(4.00, "fajitas")
            r.price(["burger", "fries", "fajitas", "salsa", "soda", "bourbon"]).should == 15.00
          end
          it "when the items are listed more than once" do
            r.add_items(2.00, "fries")
            r.price(["burger", "fries", "fries"]).should == 5.00
          end
          it "when the single line items are cheaper than the value items" do
            r.add_items(5.00, "fajitas", "salsa")
            r.add_items(1.00, "salsa")
            r.add_items(3.00, "fajitas")
            r.add_items(1.50, "burger")
            r.add_items(1.00, "fries")
            r.price(["burger", "fries", "fajitas", "salsa"]).should == 6.5
          end
        end
      end

    end
  end
end

