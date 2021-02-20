module CacheLib

  def cache_set(cache_key:, value:)
    one_minute = 60 # seconds
    timeout = one_minute * 10
    value_yaml = YAML.dump value
    res = R.setex cache_key, timeout, value_yaml
    puts "redis setex #{cache_key.inspect}: #{res}" if DEBUG
  end

  def cache_exists?(cache_key)
    R.exists? cache_key
  end

  def cache_read(cache_key:)
    value = R[cache_key]
    puts "got value from cache - #{cache_key.inspect}" if DEBUG
    value = YAML.load value
    value
  end

  def cache(cache_key, &block)
    value = if cache_exists? cache_key
      cache_read cache_key: cache_key
    else
      cache_set cache_key: cache_key, value: block.call
    end
    value
  end

end
