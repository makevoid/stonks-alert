class Uniswap

  UNISWAP_API_URL = ""

  def prices
    resp = Excon.get UNISWAP_API_URL
  end

  def self.prices
    new.prices
  end

end
