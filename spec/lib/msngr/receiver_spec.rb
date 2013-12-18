require "spec_helper"
require "msngr/receiver"

describe Msngr::Receiver do

  let(:receiver) { Msngr::Receiver.new }

  it "should initialize with a default wildcard pattern" do
    receiver.pattern.should == /.+/
  end

  it "should initialize with a custom pattern" do
    pattern = /rooms\.1/
    Msngr::Receiver.new(pattern).pattern.should == pattern
  end

  it "should define an message callback" do
    callback = proc { |msg| "invoked: #{msg}" }
    receiver.on_message(&callback)

    callbacks = receiver.on_message_callbacks
    callbacks.size.should == 1
    callbacks.first.call("message").should == "invoked: message"
  end

  it "should define an unsubscribe callback" do
    callback = proc { |msngr| "unsubscribed from: #{msngr}" }
    receiver.on_unsubscribe(&callback)

    callbacks = receiver.on_unsubscribe_callbacks
    callbacks.size.should == 1

    object = Object.new
    callbacks.first.call(object).should == "unsubscribed from: #{object}"
  end
end

