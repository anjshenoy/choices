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

  def has_items?(items)
    items = items.uniq.sort
    (@line_items.keys.flatten.uniq.sort & items) == items
  end

  def price(items)
    items.sort!
    return nil unless self.has_items?(items)
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
        remaining_items = remaining_order_items(order_items.clone, candidate.first & order_items)
        if remaining_items.size > 0
          remaining_menu_item_combo_price = find_best_price(menu_items, remaining_items, best_price_so_far)
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

  # Find all menu items who's set intersection with order items is at least one
  # Load the intersection as a hash key with the menu_item as the value.
  # If another menu_item comes along matching the same intersection (i.e. key)
  # with a lesser price, replace the hash value, otherwise move on.
  # Sort the result by the highest intersecting set first
  # Thus the possibility of finding the lowest price first is maximized.
  # For example with: [[["burger", "fries"], 3.0], [["burger", "drink", "fries"], 5.0]]
  # for an order set of ["burger"] we only need the first one as that is the best
  # price match for burger from all menu items that intersect with burger
  def relevant_matches(menu_items, order_items)
    hash = menu_items.inject({}){|result, menu_item|
      intersection_set = menu_item.first & order_items
      unless intersection_set.empty?
        if result.has_key?(intersection_set) 
          if menu_item.last < result[intersection_set].last
            result[intersection_set] = menu_item
          end
        else
          result[intersection_set] = menu_item
        end
      end
      result
    }.sort{|a,b| b.last.first.size <=> a.last.first.size}.collect(&:last)
  end

  # The order items in the first argument are actually a clone
  # of the original order_items and deleting this list will
  # therefore not affect the original one.
  def remaining_order_items(order_items, matched_items)
    matched_items.each do |m_i|
      order_items.delete_at(order_items.find_index{|o| o == m_i})
    end
    order_items
  end
end
