require "spec_helper"
require "msngr/receiver"
require "msngr/messenger"

describe Msngr::Messenger do

  let(:client) { double }
  let(:messenger) { Msngr::Messenger.new(client) }

  it "should initialize with an empty array of receivers" do
    expect(messenger.receivers).to be_empty
  end

  it "should create a new Receiver and add it to @receivers" do
    receiver = messenger.subscribe(/.+/)
    expect(messenger.receivers.count).to eq(1)
    expect(messenger.receivers.first).to eq(receiver)
  end

  it "should unsubscribe a receiver" do
    receiver = messenger.subscribe(/.+/)
    expect(messenger).to receive(:dispatch)
      .with(receiver.on_unsubscribe_callbacks, messenger)
    messenger.unsubscribe(receiver)
    expect(messenger.receivers.count).to eq(0)
  end

  it "should start listening on a separate thread" do
    expect(Thread).to receive(:new).and_yield
    expect(messenger).to receive(:loop).and_yield
    expect(messenger).to receive(:listen).once
    messenger.listen!
  end

  it "should display a backtrace on error and restart" do
    expect(Thread).to receive(:new).and_yield
    expect(messenger).to receive(:loop).and_yield
    expect(messenger).to receive(:listen).and_raise
    expect(messenger).to receive(:puts).exactly(4).times
    expect(messenger).to receive(:sleep)
    messenger.listen!
  end

  it "should listen to the client but not dispatch" do
    messenger.subscribe(/room\.2/)
    expect(client).to receive(:on_message).and_yield("room.1", "Hi John")
    expect(messenger).to receive(:dispatch).never
    messenger.send(:listen)
  end

  it "should listen to the client and dispatch a message" do
    messenger.subscribe(/room\.1/).on_message { |m| expect(m).to eq("Hi John") }
    expect(client).to receive(:on_message).and_yield("room.1", "Hi John")
    messenger.send(:listen)
  end

  it "should listen to the client and dispatch 3 messages" do
    3.times do
      messenger.subscribe(/room\.1/).tap do |receiver|
        cb = proc {}
        expect(cb).to receive(:call).with("Hi John")
        receiver.on_message(&cb)
      end
    end

    2.times do
      messenger.subscribe(/room\.2/).tap do |receiver|
        cb = proc {}
        expect(cb).to receive(:call).never
        receiver.on_message(&cb)
      end
    end

    expect(client).to receive(:on_message).and_yield("room.1", "Hi John")
    messenger.send(:listen)
  end
end
