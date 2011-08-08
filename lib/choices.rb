require_relative "restaurant"

class Choices 

  attr_reader :restaurants

  def initialize(path_to_file)
    @restaurants = {}
    File.open(path_to_file).each_line do |line|
      restaurant_id, price, *items = line.gsub("\n", "").split(", ")
      add_items(restaurant_id.to_i, price.to_f, *items)
    end
  end

  def add_items(restaurant_id, price, *items)
    if @restaurants.has_key?(restaurant_id)
      @restaurants[restaurant_id].add_items(price, *items)
    else
      @restaurants[restaurant_id] = Restaurant.new(restaurant_id, price, *items)
    end
  end

  def best_match(items)
    result = @restaurants.inject({}){|result, array|
      restaurant_id, restaurant = array
      result[restaurant_id] = restaurant.price(items)
      result
    }.select{|k,v| !v.nil?}.sort{|a,b| a.last <=> b.last}.first
    result.nil? ? "Sorry, no match found for #{items.join(", ")}" : result.join(", ")
  end

end
