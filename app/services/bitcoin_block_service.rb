require "net/http"

class BitcoinBlockService
  API_URL = "https://blockchain.info/latestblock"
  CACHE_KEY = "bitcoin_latest_block"
  CACHE_TTL = 5.minutes

  def self.current_block
    Rails.cache.fetch(CACHE_KEY, expires_in: CACHE_TTL) do
      fetch_from_api
    end
  rescue => e
    Rails.logger.error "BitcoinBlockService API error: #{e.message}"
    fetch_from_local_block
  end

  private

  def self.fetch_from_api
    uri = URI(API_URL)
    response = Net::HTTP.get(uri)
    data = JSON.parse(response)

    {
      height: data["height"],
      hash: data["hash"],
      timestamp: Time.at(data["time"])
    }
  end

  def self.fetch_from_local_block
    block = Block.order(height: :desc).first
    if block
      {
        height: block.height,
        hash: block.hash_value,
        timestamp: block.timestamp
      }
    else
      { height: 0, hash: "0" * 64, timestamp: Time.current }
    end
  end
end
