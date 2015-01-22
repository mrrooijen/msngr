require "spec_helper"
require "msngr/clients/redis"

describe Msngr::Clients::Redis do

  let(:client) { Msngr::Clients::Redis.new }

  it "should initialize without redis options" do
    expect(client.args.count).to eq(0)
  end

  it "should initialize with arguments" do
    client = Msngr::Clients::Redis.new(host: "127.0.0.1", port: 6379)
    expect(client.args).to eq([{host: "127.0.0.1", port: 6379}])
  end

  it "should establish a connection without any args" do
    expect(Redis).to receive(:new)
    client.send(:connection)
  end

  it "should establish a connection with args" do
    options = { host: "127.0.0.1", port: 6379 }
    client = Msngr::Clients::Redis.new(options)
    expect(Redis).to receive(:new).with(options)
    client.send(:connection)
  end

  it "should yield a message" do
    connection, on = double, double

    allow(client).to receive(:connection).and_return(connection)
    expect(connection).to receive(:psubscribe).with("*").and_yield(on)
    expect(on).to receive(:pmessage).and_yield("", "room.1", "John joined the room!")

    client.on_message do |event, message|
      expect(event).to eq("room.1")
      expect(message).to eq("John joined the room!")
    end
  end
end
