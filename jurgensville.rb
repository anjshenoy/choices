require "./lib/choices"
datafile, order_items = ARGV.first, ARGV[1...ARGV.size]
p order_items

choices = Choices.new(datafile)
p choices.best_match(order_items)
