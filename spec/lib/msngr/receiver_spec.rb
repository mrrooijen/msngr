require "spec_helper"
require "msngr/receiver"

describe Msngr::Receiver do

  let(:receiver) { Msngr::Receiver.new }

  it "should initialize with a default wildcard pattern" do
    expect(receiver.pattern).to eq(/.+/)
  end

  it "should initialize with a custom pattern" do
    pattern = /rooms\.1/
    expect(Msngr::Receiver.new(pattern).pattern).to eq(pattern)
  end

  it "should define an message callback" do
    callback = proc { |msg| "invoked: #{msg}" }
    receiver.on_message(&callback)

    callbacks = receiver.on_message_callbacks
    expect(callbacks.size).to eq(1)
    expect(callbacks.first.call("message")).to eq("invoked: message")
  end

  it "should define an unsubscribe callback" do
    callback = proc { |msngr| "unsubscribed from: #{msngr}" }
    receiver.on_unsubscribe(&callback)

    callbacks = receiver.on_unsubscribe_callbacks
    expect(callbacks.size).to eq(1)

    object = Object.new
    expect(callbacks.first.call(object)).to eq("unsubscribed from: #{object}")
  end
end
