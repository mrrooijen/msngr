module Msngr
  require "msngr/version"
  require "msngr/clients"
  require "msngr/receiver"
  require "msngr/messenger"

  extend self

  # Shorthand for writing Msngr::Messenger.new(*args).
  #
  # @param [Array] *args
  #
  # @return [Msngr::Messenger]
  #
  def new(*args)
    Messenger.new(*args)
  end
end
