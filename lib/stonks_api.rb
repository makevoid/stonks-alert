module StonksAPI

  def stonk_price(ticker_symbol:)
    symbol = ticker_symbol.to_s
    stock = Alphavantage::Stock.new symbol: symbol, key: KEY_STONKS_API
    quote = stock.quote
    quote = quote.output["Global Quote"]
    price = quote["05. price"]
    puts "price: #{price} (low: #{quote["04. low"]}, high: #{quote["03. high"]})"
    price.to_f
  end

end

# class StonksAPI
#
#   def initialize(symbol:)
#     @symbol = symbol
#   end
#
#   def price
#     # ...
#   end
#
#   def self.price(ticker_symbol:)
#     new(symbol: ticker_symbol).price
#   end
#
# end
