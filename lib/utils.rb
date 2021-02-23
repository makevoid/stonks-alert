module Utils

  def list_prices(prices:)
    puts "\nResults:"
    prices.each do |price|
      puts "#{price.f :ticker}:\t\t#{price.f :price}"
    end
    puts "\n"
  end

end
