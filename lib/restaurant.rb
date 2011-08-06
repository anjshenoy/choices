class Restaurant

  WORD_DELIMITER = ", "
  attr_reader :id, :line_items

  def initialize(id, price, *items)
    @id, @line_items = id, Hash.new(0)
    add_items(price, *items)
  end


  def add_items(price, *items)
    if items.empty?
      raise ArgumentError.new("Data Error:: Item required in order to proceed")
    end
    @line_items[items.sort] = price
  end

  def has_items?(*items)
    menu_items_include_items?(@line_items.keys.flatten.uniq.sort, items)
  end

  def price(*items)
    return nil unless self.has_items?(*items)
    items.sort!
    prices = {}
    items.each do |item|
      prices.merge!(@line_items.select{|menu_items, value| menu_items.include?(item)})
    end
    prices[items] || find_inclusive_prices(prices, items)
  end

  private
  def find_inclusive_prices(prices, items)
    prices.select{|menu_items, value| 
      menu_items_include_items?(menu_items, items)
    }.values.min
  end

  def menu_items_include_items?(key, items)
    items.all?{|item| key.include?(item)}
  end
end
