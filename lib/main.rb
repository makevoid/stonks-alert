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

def send_alert(ticker:, price:)
  message = "ticker #{ticker} reached price #{price}"
  puts "sending SMS - #{message}"
  send_smses message: message
end

def check_stocks
  stock_tickers = STONKS
  prices = stock_tickers.map do |stock|
    ticker_name = stock.first
    cache(ticker_name) do
      process_stock_ticker stock: stock
    end
    sleep 15
  end.compact

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

def time_out
  one_minute = 60
  sleep one_minute * 10
end

def main
  loop do
    check_stocks
    time_out
  end
end

main
