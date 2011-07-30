class Restaurant

  attr_reader :id, :single_items, :value_items

  def initialize(id, price, *items)
    @id, @single_items, @value_items = id, [], []
    if items.size == 1
      @single_items << {items.first => price}
    else
      @value_items << {items => price}
    end

    if items.empty?
      raise ArgumentError.new("Data Error:: Item required in order to proceed")
    end
  end


  def add_items(price, *items)
    if items.size == 1
      @single_items << {items.first => price}
    else
      @value_items << {items => price}
    end
    self
  end

  
end
