class Restaurant

  attr_reader :id, :single_items, :value_items

  def initialize(id, price, *items)
    @id, @single_items, @value_items = id, Hash.new(0), Hash.new(0)
    add_items(price, *items)
  end


  def add_items(price, *items)
    if items.size == 1
      @single_items[items.first] = price
    else
      @value_items[items.sort.join("_")] = price
    end
    if items.empty?
      raise ArgumentError.new("Data Error:: Item required in order to proceed")
    end
  end

  #TODO: remove this if its not being used
  def has_items?(*items)
    items.each do |item|
      unless @single_items.has_key?(item) || has_item_in_value_items?(item)
        return false
      end
    end
    true
  end

  def all_price_combinations
    @single_items.merge((2..@single_items.size).inject({}){|result, size|
      @single_items.keys.combination(size).each {|key_combo| 
        result[key_combo.sort.flatten.join("_")] = key_combo.inject(0){|sum, key| sum += @single_items[key]}
      }
      result
    }).merge(@value_items)
  end

  def price(*items)
    items.sort!
    item_combinations = items.size.downto(1).inject([]){|result, size|
      items.combination(size).each{|item_combo| result << item_combo}
      result
    }.map{|i| i.join("_")}
    valid_price_combos = item_combinations.inject({}) do |result, item_combo|
      if all_price_combinations.has_key?(item_combo)
        result[item_combo] = all_price_combinations[item_combo]
      end
      result
    end
    valid_price_combos.inject({}){|result, array|
      key, value = array
      result[key] = valid_price_combos[key] if (result.keys.map{|k| k.split("_")}.flatten & key.split("_")).empty?
      result
    }.values.inject(&:+)
  end

  private
  def has_item_in_value_items?(item)
    @value_items.each do |key, value|
      return true if key.include? item
    end
    false
  end
end
