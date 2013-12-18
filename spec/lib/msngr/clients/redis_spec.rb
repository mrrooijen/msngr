require "spec_helper"
require "msngr/clients/redis"

describe Msngr::Clients::Redis do

  let(:client) { Msngr::Clients::Redis.new }

  it "should initialize without redis options" do
    client.should have(0).args
  end

  it "should initialize with arguments" do
    client = Msngr::Clients::Redis.new(host: "127.0.0.1", port: 6379)
    client.args.should == [{host: "127.0.0.1", port: 6379}]
  end

  it "should establish a connection without any args" do
    Redis.expects(:new)
    client.send(:connection)
  end

  it "should establish a connection with args" do
    options = { host: "127.0.0.1", port: 6379 }
    client = Msngr::Clients::Redis.new(options)
    Redis.expects(:new).with(options)
    client.send(:connection)
  end

  it "should yield a message" do
    connection, on = mock, mock

    client.stubs(:connection).returns(connection)
    connection.expects(:psubscribe).with("*").yields(on)
    on.expects(:pmessage).yields("", "room.1", "John joined the room!")

    client.on_message do |event, message|
      event.should == "room.1"
      message.should == "John joined the room!"
    end
  end
end

