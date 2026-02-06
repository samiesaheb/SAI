class Block < ApplicationRecord
  BLOCK_INTERVAL = 10.minutes # New block every 10 minutes (like Bitcoin's ~10 min)

  validates :height, presence: true, uniqueness: true
  validates :timestamp, presence: true
  validates :hash_value, presence: true, uniqueness: true

  before_validation :generate_hash, on: :create

  scope :by_height, -> { order(height: :desc) }

  class << self
    def current
      by_height.first || genesis!
    end

    def current_height
      current.height
    end

    def genesis!
      create!(
        height: 0,
        timestamp: Time.current,
        previous_hash: "0" * 64
      )
    end

    def mine!
      previous = current
      create!(
        height: previous.height + 1,
        timestamp: Time.current,
        previous_hash: previous.hash_value
      )
    end

    def blocks_until(target_block)
      return 0 if target_block <= current_height
      target_block - current_height
    end

    def time_until(target_block)
      blocks_until(target_block) * BLOCK_INTERVAL
    end

    def block_at_time(future_time)
      blocks_needed = ((future_time - Time.current) / BLOCK_INTERVAL).ceil
      current_height + blocks_needed
    end
  end

  def formatted_timestamp
    timestamp.strftime("%Y-%m-%d %H:%M:%S UTC")
  end

  def short_hash
    hash_value[0..7]
  end

  private

  def generate_hash
    return if hash_value.present?
    data = "#{height}#{timestamp}#{previous_hash}#{SecureRandom.hex(16)}"
    self.hash_value = Digest::SHA256.hexdigest(data)
  end
end
