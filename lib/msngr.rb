require "msngr/version"
require "msngr/receiver"
require "msngr/messenger"

module Msngr
  module Clients; end
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

