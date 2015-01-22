require "thread"

class Msngr::Messenger

  # A client object interface to receive messages from.
  #
  # @return [Msngr::Clients::*]
  #
  attr_reader :client

  # An Array of Receiver objects to dispatch callbacks/messages to.
  #
  # @return [Array<Receiver>]
  #
  attr_reader :receivers

  # Initializes a new Messenger.
  #
  # @param [Msngr::Clients::*] client the to receive messages from.
  #
  # @return [Receiver]
  #
  def initialize(client)
    @client = client
    @receivers = []
    @mutex = Mutex.new
  end

  # Creates and returns a new Receiver and adds it to @receivers so
  # it'll receive messages matching the provided pattern.
  #
  # @param [Regexp] pattern
  #
  # @return [Receiver]
  #
  def subscribe(pattern)
    Msngr::Receiver.new(pattern).tap do |receiver|
      @mutex.synchronize { @receivers << receiver }
    end
  end

  # Removes the Receiver from @receivers and invokes the receiver's
  # @on_unsubscribe_callbacks.
  #
  # @param [Receiver] receiver
  #
  def unsubscribe(receiver)
    @mutex.synchronize { @receivers.delete(receiver) }
    dispatch(receiver.on_unsubscribe_callbacks, self)
  end

  # Listens on a new thread. Will auto-restart when crashed
  # in an attempt to recover from exceptions.
  #
  def listen!
    Thread.new do
      loop do
        begin
          listen
        rescue => e
          puts "Messenger error occurred:"
          puts "#{e.class.name}"
          puts "#{e.backtrace.join("\n")}"
          puts "Restarting.."
          sleep 1
        end
      end
    end
  end

  private

  # Instructs the @client to yield events/messages when it receives them. Received
  # events are matched with each Receiver's pattern and will dispatch the event's message
  # to all subscribing Receiver instances that match the event's pattern.
  #
  def listen
    client.on_message do |event, message|
      subscribing_receivers(event) do |receiver|
        dispatch(receiver.on_message_callbacks, message)
      end
    end
  end

  # Yields Receiver objects who's pattern matches the event.
  #
  # @param [String] event
  # @yield [Receiver]
  #
  def subscribing_receivers(event)
    receivers.each do |receiver|
      yield receiver if receiver.pattern.match(event)
    end
  end

  # Dispatches args to the provided callbacks.
  #
  # @param [Array<Proc>] callbacks
  # @param [Array] *args an Array of arguments to call each Proc with.
  #
  def dispatch(callbacks, *args)
    callbacks.each { |callback| callback.call(*args) }
  end
end
