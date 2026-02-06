# Create genesis block
unless Block.any?
  Block.genesis!
  puts "Created genesis block"
end

puts "Current block height: #{Block.current_height}"
