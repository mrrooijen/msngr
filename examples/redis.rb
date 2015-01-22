$:.unshift(File.expand_path("../lib", __FILE__))

require "msngr"
require "msngr/clients/redis"

redis = Redis.new
client = Msngr::Clients::Redis.new
messenger = Msngr.new(client).tap(&:listen!)

r1, r2, r3 = (1..3).map do |n|
  messenger.subscribe(/room\.#{n}/).tap do |receiver|
    receiver.on_message { |msg| puts "Receiver #{n}: #{msg}" }
    receiver.on_unsubscribe { |msngr| puts "Unsubscribed Receiver #{n} from: #{msngr}" }
  end
end

r4 = messenger.subscribe(/.+/).tap do |receiver|
  receiver.on_message { |msg| puts "Receiver 4: #{msg}" }
  receiver.on_unsubscribe { |msngr| puts "Unsubscribed Receiver 4 from: #{msngr}" }
end

binding.pry
