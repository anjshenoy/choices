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
    if has_items?(*items)
      items.sort!
      item_combinations(items).inject({}){|result_hash, item_combos|
        if all_price_combinations_include?(item_combos)
          result_hash[item_combos] = 
            item_combos.inject(0){|sum, item| 
              item = item.join if item.is_a? Array
              sum += all_price_combinations[item]
            }
        end
        result_hash
      }.values.min
    else
      nil
    end
  end

  private
  def has_item_in_value_items?(item)
    @value_items.each do |key, value|
      return true if key.include? item
    end
    false
  end

  def item_combinations(items)
    # 2..n-1 item combinations
    result = (2...items.size).inject([]) do |inner_result, i|
      items.combination(i).each do |item_combo|
        inner_result << ([item_combo.join("_")] + (items - item_combo))
      end
      inner_result
    end
    result += [items.combination(1).to_a] + [[items.combination(items.size).to_a.join("_")]]
    result
  end

  def all_price_combinations_include?(item_combos)
    item_combos.each do |key|
      key = key.join if key.is_a? Array
      return false unless all_price_combinations.keys.include?(key)
    end
    true
  end

end
