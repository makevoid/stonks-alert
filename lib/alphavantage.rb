# TODO: implement an alternative to the alphavantage gem using the tickers api and excon

require_relative 'env'

class JSONParseError < RuntimeError
  def message
    "JSONParseError - ignoring the ticker for this run"
  end
end

class ConnectionError < RuntimeError
  def message
    "ConnectionError - ignoring any connection error (look at the logs for the specific error)"
  end
end

module AlphavantageLibCrypto

  def alphavantage_crypto_url(symbol:)
    symbol = symbol.to_s
    if symbol == "BTC"
      ALPHAVANTAGE_CRYPTO_URL % "BTC"
    else
      ALPHAVANTAGE_CRYPTO2CRYPTO_URL % symbol
    end
  end

  def price_crypto_raw(symbol:)
    url = alphavantage_crypto_url symbol: symbol
    http = Excon.new url
    resp  = http.get
    resp  = JSON.parse resp.body
    p resp if DEBUG
    resp
  end

  def price_crypto(symbol:)
    price = price_crypto_raw symbol: symbol
    begin
      price = price.f "Realtime Currency Exchange Rate"
    rescue KeyError => err
      return 0
    end
    price = price.f "5. Exchange Rate"
    p price if DEBUG
    price.to_f.round 7
  rescue JSON::ParserError => err
    0
  rescue Excon::Error::Timeout, Excon::Error::Socket, SocketError => err # TODO: extract to custom exception
    0
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
    begin
      resp  = JSON.parse resp.body
    rescue JSON::ParserError => err
      puts "ignoring json ticker (json parse error)"
      raise JSONParseError
    rescue Excon::Error::Timeout, Excon::Error::Socket, SocketError => err # TODO: extract to custom exception
      puts "ignoring connection error - #{err.inspect}"
      raise ConnectionError
    end
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
  include AlphavantageLibCrypto

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

  def check_price_crypto
    price_crypto symbol: ticker
  end

  def self.price_crypto(ticker:)
    new(ticker: ticker).check_price_crypto
  end

end

# Usage:
#
#   Alphavantage.price ticker: "AAPL" #=> 123.45 ($ - 5 min ago or market/day close price)
#

if __FILE__ == $0

  def stonks_check
    symbol = "AAPL"
    price = stonk_price ticker_symbol: symbol
    puts "#{symbol}: #{price}"
  end

  def crypto_check
    symbol = "ETH"
    price = crypto_price symbol: symbol
    puts "#{symbol}: #{price}"
  end

  def main
    crypto_check
    # stonks_check
  end

  main

end
