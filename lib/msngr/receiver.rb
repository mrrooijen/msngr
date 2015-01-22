require "thread"

class Msngr::Receiver

  # Event pattern to match.
  #
  # @return [String]
  #
  attr_reader :pattern

  # Array of Procs to invoke when a message is received.
  #
  # @return [Array<Proc>]
  #
  attr_reader :on_message_callbacks

  # Array of Procs to invoke when unsubscribed from a Messenger.
  #
  # @return [Array<Proc>]
  #
  attr_reader :on_unsubscribe_callbacks

  # Initializes a new Receiver.
  #
  # @param [Regexp] pattern the pattern to listen for.
  #
  # @return [Receiver]
  #
  def initialize(pattern = /.+/)
    @pattern = pattern
    @on_message_callbacks = []
    @on_unsubscribe_callbacks = []
    @mutex = Mutex.new
  end

  # Define a callback that invokes on each received message.
  #
  # @param [Proc] block
  #
  # @example
  #   receiver.on_message do |message|
  #     puts "Message Received: #{message}"
  #   end
  #
  def on_message(&block)
    @mutex.synchronize { @on_message_callbacks << block }
  end

  # Define a callback that invokes when unsubscribed from a Messenger.
  #
  # @param [Proc] block
  #
  # @example
  #   receiver.on_unsubscribe do |messenger|
  #     puts "Unsubscribed From: #{messenger}"
  #   end
  #
  def on_unsubscribe(&block)
    @mutex.synchronize { @on_unsubscribe_callbacks << block }
  end
end
