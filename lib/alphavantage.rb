# TODO: implement an alternative to the alphavantage gem using the tickers api and excon

require_relative 'env'

AALPHAVANTAGE_API_KEY = KEY_STONKS_API
ALPHAVANTAGE_TICKERS_URL = "https://www.alphavantage.co/query?function=TIME_SERIES_INTRADAY&symbol=%s&interval=5min&apikey=#{AALPHAVANTAGE_API_KEY}"
# TODO: https://www.alphavantage.co/query?function=GLOBAL_QUOTE&symbol=IBM&apikey=demo # TODO: check this api

# crypto

# ALPHAVANTAGE_CRYPTO_URL = https://www.alphavantage.co/query?function=CURRENCY_EXCHANGE_RATE&from_currency=%s&to_currency=USD&apikey=demo
# ALPHAVANTAGE_CRYPTO2CRYPTO_URL = https://www.alphavantage.co/query?function=CURRENCY_EXCHANGE_RATE&from_currency=%s&to_currency=BTC&apikey=demo

# TODO: move
def alphavantage_crypto_url(symbol:)
  if crypto == "BTC"
    ALPHAVANTAGE_CRYPTO_URL % "BTC"
  else
    ALPHAVANTAGE_CRYPTO2CRYPTO_URL % crypto
  end
end

module AlphavantageLib

  LABELS = { # format: OHLCV
    open:   "1. open",
    high:   "2. high",
    low:    "3. low",
    close:  "4. close",
    volume: "5. volume",
  }

  def tickers_raw(symbol:)
    http = Excon.new ALPHAVANTAGE_TICKERS_URL % symbol
    resp  = http.get
    resp  = JSON.parse resp.body
    p resp if DEBUG
    resp
  end

  def tickers(symbol:)
    ticks = tickers_raw symbol: symbol
    ticks = ticks.f "Time Series (5min)"
    tick = ticks.first
    puts "Tickers:\n#{tick}" if DEBUG
    tick
  end

  def ticker_price(ticker:)
    date, ticker_data = ticker.first, ticker.last
    price = mid_price ticker: ticker_data
    puts "price: #{price}" if DEBUG
    price
  end

  def mid_price(ticker:)
    low   = ticker.f LABELS[:low]
    high  = ticker.f LABELS[:high]
    ((low.to_f + high.to_f) / 2).round 2
  end

  def stonk_price(ticker_symbol:)
    ticker  = tickers symbol: ticker_symbol
    ticker_price ticker: ticker
  end

end

class Alphavantage

  include AlphavantageLib

  attr_reader :ticker

  def initialize(ticker:)
    @ticker = ticker
  end

  def price
    stonk_price ticker_symbol: ticker
  end

  def self.price(ticker:)
    new(ticker: ticker).price
  end

end

# Usage:
#
#   Alphavantage.price ticker: "AAPL" #=> 123.45 ($ - 5 min ago or market/day close price)
#

if __FILE__ == $0

  def main
    symbol = "AAPL"
    price = stonk_price ticker_symbol: symbol
    puts "#{symbol}: #{price}"
  end

  main

end
