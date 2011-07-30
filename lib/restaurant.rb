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
      @value_items[items] = price
    end
    if items.empty?
      raise ArgumentError.new("Data Error:: Item required in order to proceed")
    end
  end

  def all_items
    (@single_items.keys + @value_items.keys.flatten).uniq
  end

  def has_item?(item)
    all_items.include?(item)
  end
end
