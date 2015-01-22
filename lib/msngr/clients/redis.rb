require "redis"

class Msngr::Clients::Redis

  # (Connectivity) Arguments to initialize the Redis instance with.
  #
  # @return [Array]
  #
  attr_reader :args

  # Instantiances an instance of Msngr::Clients::Redis.
  #
  # @param [Array] *args the arguments to pass in to the Redis client.
  #
  def initialize(*args)
    @args = args
  end

  # Yields all events/messages from the Redis server.
  #
  # @yield [event, message]
  # @yieldparam [String] event the name of the received event.
  # @yieldparam [String] message the message of the received event.
  #
  # @note This is an interface for Msngr::Messenger.
  #
  def on_message
    connection.psubscribe("*") do |on|
      on.pmessage { |_, event, message| yield event, message }
    end
  end

  private

  # Creates and returns a new instance of Redis using @args if present.
  #
  # @return [Redis]
  #
  def connection
    if args.any?
      Redis.new(*args)
    else
      Redis.new
    end
  end
end
