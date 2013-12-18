require "spec_helper"
require "msngr/receiver"
require "msngr/messenger"

describe Msngr::Messenger do

  let(:client)    { mock }
  let(:messenger) { Msngr::Messenger.new(client) }

  it "should initialize with an empty array of receivers" do
    messenger.receivers.should be_empty
  end

  it "should create a new Receiver and add it to @receivers" do
    receiver = messenger.subscribe(/.+/)
    messenger.should have(1).receivers
    messenger.receivers.first.should == receiver
  end

  it "should unsubscribe a receiver" do
    receiver = messenger.subscribe(/.+/)
    messenger.expects(:dispatch).
      with(receiver.on_unsubscribe_callbacks, messenger)
    messenger.unsubscribe(receiver)
    messenger.should have(0).receivers
  end

  it "should start listening on a separate thread" do
    Thread.expects(:new).yields
    messenger.expects(:loop).yields
    messenger.expects(:listen).once
    messenger.listen!
  end

  it "should display a backtrace on error and restart" do
    Thread.expects(:new).yields
    messenger.expects(:loop).yields
    messenger.expects(:listen).raises.then.returns
    messenger.expects(:puts).times(4)
    messenger.expects(:sleep)
    messenger.listen!
  end

  it "should listen to the client but not dispatch" do
    messenger.subscribe(/room\.2/)
    client.expects(:on_message).yields("room.1", "Hi John")
    messenger.expects(:dispatch).never
    messenger.send(:listen)
  end

  it "should listen to the client and dispatch a message" do
    messenger.subscribe(/room\.1/).on_message { |m| m.should == "Hi John" }
    client.expects(:on_message).yields("room.1", "Hi John")
    messenger.send(:listen)
  end

  it "should listen to the client and dispatch 3 messages" do
    3.times do
      messenger.subscribe(/room\.1/).tap do |receiver|
        cb = proc {}
        cb.expects(:call).with("Hi John")
        receiver.on_message(&cb)
      end
    end

    2.times do
      messenger.subscribe(/room\.2/).tap do |receiver|
        cb = proc {}
        cb.expects(:call).never
        receiver.on_message(&cb)
      end
    end

    client.expects(:on_message).yields("room.1", "Hi John")
    messenger.send(:listen)
  end
end

