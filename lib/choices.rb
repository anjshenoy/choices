require_relative "restaurant"

class Choices 

  attr_reader :restaurants

  def initialize(restaurant_id, price, *items)
    @restaurants = {}
    add_items(restaurant_id, price, *items)
  end

  def add_items(restaurant_id, price, *items)
    if @restaurants.has_key?(restaurant_id)
      @restaurants[restaurant_id].add_items(price, *items)
    else
      @restaurants[restaurant_id] = Restaurant.new(restaurant_id, price, *items)
    end
  end

  #TODO :test for empty items
  def best_match(*items)
    @restaurants.inject({}){|result, array|
      restaurant_id, restaurant = array
      result[restaurant_id] = restaurant.price(*items)
      result
    }.select{|k,v| !v.nil?}.sort{|a,b| a.last <=> b.last}.first.join(", ")
  end


end
