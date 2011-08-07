class Restaurant

  WORD_DELIMITER = ", "
  attr_reader :id, :line_items

  def initialize(id, price, *items)
    @id, @line_items = id, {}
    add_items(price, *items)
  end


  def add_items(price, *items)
    if items.empty?
      raise ArgumentError.new("Data Error:: Item required in order to proceed")
    end
    @line_items[items.sort] = price
  end

  def has_items?(*items)
    (@line_items.keys.flatten.uniq.sort & items.sort!) == items
  end

  def price(*items)
    return nil unless self.has_items?(*items)
    items.sort!
    @line_items[items] || all_prices_by_relevant_match(@line_items.to_a, items).keys.min
  end

  private
  def all_prices_by_relevant_match(menu_items, items, price_combinations={}, individual_prices={})
    relevant_matches(menu_items, items).each do |array|
      keys, price = array
      puts "keys = #{keys}"
      intersection_set = keys & items
      if intersection_set.size > 0
        individual_prices.merge!({keys => price})
        menu_items.delete_if{|arr| puts "arr = #{arr}"; (arr.first & keys) == keys}
        puts "menu_items = #{menu_items}"
      end
      p "individual_prices = " + individual_prices.inspect
      remaining_items = items - intersection_set
      sum_so_far = individual_prices.values.inject(&:+)
      puts sum_so_far
      if remaining_items.empty?
        price_combinations.merge!({sum_so_far => individual_prices})
        p price_combinations
        individual_prices = {}
      else
        puts "calling recursive on individual_prices"
        puts remaining_items
        puts sum_so_far
        if sum_so_far < price_combinations.keys.min.to_i
          all_prices_by_relevant_match(menu_items, remaining_items, price_combinations, individual_prices)
        end
      end
    end
    price_combinations
  end

  def relevant_matches(list, items)
    list.select{ |array| 
      (array.first & items).size > 0
    }
  end
end
