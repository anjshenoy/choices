require "./lib/choices"
datafile, order_items = ARGV

choices = Choices.new(datafile)
p choices.best_match(order_items)
