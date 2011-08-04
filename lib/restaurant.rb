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
    items.each do |item|
      puts "item = #{item}"
      key_matches = @line_items.keys.select{|k| k.include?(item)}
      prices = []
      key_matches.each do |key|
        puts "key = #{key}"
        prices << @line_items[key]
      end
      puts prices.inspect
    end
    if items.size == 1
      return @line_items[[items.first]]
    end
  end
end
