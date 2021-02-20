module Utils

  def list_prices(prices:)
    puts "\nResults:"
    prices.each do |price|
      puts "#{price.f :ticker}: #{price.f :price}"
    end
  end

end
