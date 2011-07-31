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

  def price_combinations(*items)
    price_result = {}
    (1..items.length).inject([]){|result, size|
      items.combination(size).each {|combo| result << combo} 
      result
    }.each do |items|
      if has_items?(*items)
        price_result[items.first] = @single_items[items.first] if items.size == 1 && @single_items.has_key?(items.first)
        @value_items.each_pair do |value_combo, price|
          price_result[value_combo] = price if value_combo.join(", ").include?(items.join(","))
        end
      end
    end
    if price_result.empty?
      nil
    else
      price_result
    end
  end

  private
  def has_item_in_value_items?(item)
    @value_items.each do |key, value|
      return true if key.include? item
    end
    false
  end
end
