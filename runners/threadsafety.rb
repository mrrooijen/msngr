$:.unshift(File.expand_path("../../lib", __FILE__))

require "ostruct"
require "parallel"
require "msngr"

client    = OpenStruct.new
messenger = Msngr.new(client)

Parallel.each(1..10_000, in_threads: 8) { messenger.subscribe(/.+/) }

puts "subscribe      | done: #{messenger.receivers.size}"

receiver = messenger.receivers.first
Parallel.each(1..10_000, in_threads: 8) do
  receiver.on_message { |msg| "John: #{msg}" }
  receiver.on_unsubscribe { |msngr| "Gone: #{msngr}" }
end

puts "on_message     | done: #{receiver.on_message_callbacks.size}"
puts "on_unsubscribe | done: #{receiver.on_unsubscribe_callbacks.size}"

receivers = messenger.receivers.dup
Parallel.each(receivers, in_threads: 8) { |receiver| messenger.unsubscribe(receiver) }

puts "unsubscribe    | done: #{messenger.receivers.size}"
