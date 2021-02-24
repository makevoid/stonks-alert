module StonksAPI

  def stonk_price(ticker_symbol:)
    Alphavantage.price ticker: ticker_symbol
  end

  # def stonk_price_alphavantage_gem_legacy(ticker_symbol:)
  #   symbol = ticker_symbol.to_s
  #   stock = Alphavantage::Stock.new symbol: symbol, key: KEY_STONKS_API
  #   quote = stock.quote
  #   quote = quote.output["Global Quote"]
  #   price = quote["05. price"]
  #   puts "price: #{price} (low: #{quote["04. low"]}, high: #{quote["03. high"]})"
  #   price.to_f
  # end

end
