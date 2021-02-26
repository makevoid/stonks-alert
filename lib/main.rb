require_relative 'env'

def process_stock_ticker(stock:)
  ticker, price_alerts = stock.first, stock.last.sort
  price_alert_low, price_alert_high = price_alerts.first, price_alerts.last
  price = stonk_price ticker_symbol: ticker

  puts "#{ticker}: #{price}"
  {
    ticker: ticker,
    price:  price,
    alerts: [price_alert_low, price_alert_high],
    _alerts: {
      low:  price_alert_low,
      high: price_alert_high,
    },
  }
end

def process_crypto_ticker(crypto:)
  ticker, price_alerts = crypto.first, crypto.last.sort
  price_alert_low, price_alert_high = price_alerts.first, price_alerts.last
  price = crypto_price ticker_symbol: ticker

  puts "#{ticker}: #{price}"
  {
    ticker: ticker,
    price:  price,
    alerts: [price_alert_low, price_alert_high],
    _alerts: {
      low:  price_alert_low,
      high: price_alert_high,
    },
  }
end

def send_sms(message:, recipient:)
  sms = SMS.new.deliver to: recipient, message: message
  p sms
  sms
end

def send_smses(message:)
  SMS_RECIPIENTS.map do |recipient|
    send_sms message: message, recipient: recipient
  end
end

def sms_sent_recently?(ticker:)
  one_minute = 60 # seconds
  outcome = true
  outcome = false if R["smses:#{ticker}"]
  timeout = one_minute * 60
  R.setex "smses:#{ticker}", timeout, "1"
  outcome
end

def send_alert(ticker:, price:)
  message = "ticker #{ticker} reached price #{price}"
  # don't alert if last alert was on the same ticker for
  return false if sms_sent_recently? ticker: ticker
  puts "sending SMS - #{message}"
  send_smses message: message
end

def process_stock_ticker_cached(stock:)
  cache(ticker_name) do
    value = process_stock_ticker stock: stock
    sleep DAILY_REQUEST_LIMIT_DELAY
    value
  end
end

def check_stonks_only
  stock_tickers = STONKS
  stock_tickers.map do |stock|
    ticker_name = stock.first
    # process_stock_ticker_cached stock: stock # just for DEV
    price = process_stock_ticker stock: stock
    sleep DAILY_REQUEST_LIMIT_DELAY
    price
  end.compact
end

def check_cryptos
  crypto_tickers = CRYPTOS
  crypto_tickers.map do |crypto|
    ticker_name = crypto.first
    price = process_crypto_ticker crypto: crypto
    sleep DAILY_REQUEST_LIMIT_DELAY
    price
  end.compact
end

def check_stonks
  prices = []
  prices += check_stonks_only
  prices += check_cryptos

  list_prices prices: prices

  prices = prices.map do |price|
    unless price.f(:price) == 0
      price
    else
      puts "Price of #{price.f :ticker} was not fetched correctly"
      nil
    end
  end.compact

  prices.each do |price|
    price_crossed = true unless Range.new(*price.f(:alerts)).include? price.f(:price)
    ticker = price.f :ticker
    send_alert ticker: ticker, price: price.f(:price) if price_crossed
    # send_alert ticker: ticker, price: price, threshold: threshold if price_crossed
  end
end

def main
  loop do
    check_stonks
  end
end

main
