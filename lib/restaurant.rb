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
    keys = @line_items.keys.flatten.uniq.sort
    items.each do |item|
      return false unless keys.include?(item)
    end
    true
  end

  def price(*items)
    return nil unless self.has_items?(*items)
    items.sort!
    prices = {}
    items.each do |item|
      keys = @line_items.keys.select{|k| k.include?(item)}
      keys.each do |key|
        prices[key] = @line_items[key]
      end
    end
    prices[items] || prices.select{|k,v| k.include?(items.join(WORD_DELIMITER))}.values.min
  end
end
