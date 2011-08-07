class Restaurant

  attr_reader :id, :line_items

  def initialize(id, price, *items)
    if id.to_i == 0
      raise ArgumentError.new("Data Error:: Restaurant ID: #{id} is not acceptable. Please correct the data file")
    end
    @id, @line_items = id, {}
    add_items(price, *items)
  end


  def add_items(price, *items)
    if items.empty?
      raise ArgumentError.new("Data Error:: Menu items are missing for Restaurant ID: #{@id} and are required in order to proceed")
    elsif price.to_f == 0.0
      raise ArgumentError.new("Data Error:: Price is invalid for restaurant ID:#{@id} and is required in order to proceed")
    end
    @line_items[items.sort] = price
  end

  def has_items?(*items)
    items.sort!
    (@line_items.keys.flatten.uniq.sort & items) == items
  end

  def price(*items)
    items.sort!
    return nil unless self.has_items?(*items)
    @line_items[items] || find_best_price(@line_items.to_a, items).collect(&:last).inject(&:+)
  end

  private
  def find_best_price(menu_items, order_items, best_price_so_far = 1000000)
    price_combinations =[] 
    local_best_combination = []
    relevant_matches(menu_items, order_items).each do |candidate|
      if candidate.last < best_price_so_far
        if candidate.first == order_items
          return [candidate]
        end
        local_best_combination = [candidate]
        matched_items = candidate.first & order_items
        remaining_items = order_items - matched_items
        if remaining_items.size > 0
          remaining_menu_item_combo_price = find_best_price(menu_items - candidate, remaining_items, best_price_so_far)
          unless remaining_menu_item_combo_price.nil?
            local_best_combination += remaining_menu_item_combo_price
          end
        end
        best_price_so_far = local_best_combination.collect(&:last).inject(&:+)
      end
      if price_combinations.empty? || price_combinations.collect(&:last).inject(&:+) > best_price_so_far
        price_combinations = local_best_combination
      end
    end
    price_combinations
  end

  def relevant_matches(menu_items, order_items)
    menu_items.select{|keys, price|
      (keys & order_items).size > 0
    }.sort{|a,b| b.first.size <=> a.first.size}
  end
end
