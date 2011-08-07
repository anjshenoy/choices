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
    @line_items[items] || find_price_by_relevant_match(items)
  end

  private
  def find_price_by_relevant_match(items)
    @line_items.select{|menu_items, price| 
      (menu_items & items).size > 0
    }.values.first
  end
end
