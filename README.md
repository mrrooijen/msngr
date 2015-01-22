# Msngr

[![Gem Version](https://badge.fury.io/rb/msngr.svg)](http://badge.fury.io/rb/msngr)
[![Build Status](https://travis-ci.org/meskyanichi/msngr.png)](https://travis-ci.org/meskyanichi/msngr)
[![Code Climate](https://codeclimate.com/github/meskyanichi/msngr.png)](https://codeclimate.com/github/meskyanichi/msngr)

A light-weight Ruby library for multi-threaded Ruby applications that allows threads to share a single service connection for more efficient messaging.

This library was sponsored by [HireFire].

The documentation can be found on [RubyDoc].


### Compatibility

- Ruby (MRI) 2.0+


### Installation

Add the gem to your Gemfile and run `bundle`.

```rb
gem "msngr"
```


## Usage

Consider a Rails 4 application with websocket support using Rack Hijack through [Tubesock], and you want to use the Redis service as a message queue.

*Note: This gem isn't Rails- or Tubesock-specific. This is just an example.*

```rb
# In an initializer
REDIS = Redis.new

# A controller
class MainController < ApplicationController
  include Tubesock::Hijack

  def connection
    hijack do |websocket|
      redis = Thread.new do
        Redis.new.subscribe("chatroom") do |on|
          on.message { |_, message| websocket.send_data(message) }
        end
      end

      websocket.onmessage { |message| REDIS.publish("chatroom", message) }
      websocket.onclose { redis.kill }
    end
  end
end
```

The above would work, however each web socket connection would require:

* A Ruby Thread for the web socket connection (Puma App Server)
* A Ruby Thread for the Hijack (Tubesock)
* A Ruby Thread for the Redis Connection to allow the blocking subscribe operation
* A Redis Connection to subscribe

Now consider the following setup with Msngr:

```rb
# In an initializer
require "msngr/clients/redis"

client    = Msngr::Clients::Redis.new
MESSENGER = Msngr.new(client).tap(&:listen!)
REDIS     = Redis.new

# A controller
class MainController < ApplicationController
  include Tubesock::Hijack

  def connection
    hijack do |websocket|
      receiver = MESSENGER.subscribe(/chatroom/)

      websocket.onopen do
        receiver.on_message { |message| websocket.send_data(message) }
        receiver.on_unsubscribe { REDIS.publish("chatroom", "You left the chat.") }
      end

      websocket.onmessage { |message| REDIS.publish("chatroom", message) }
      websocket.onclose { MESSENGER.unsubscribe(receiver) }
    end
  end
end
```

For each web socket connection with this setup the resource requirements are:

* A Ruby Thread for the web socket connection (Puma App Server)
* A Ruby Thread for the Hijack (Tubesock)

This means that each request will require 2 Ruby Threads (instead of 3), and no additional Redis connections.

## Explanation

This part:

```rb
require "msngr/clients/redis"

client    = Msngr::Clients::Redis.new
MESSENGER = Msngr.new(client).tap(&:listen!)
REDIS     = Redis.new
```

The `client` is an interface object that acts as a Redis client. This will use a single Redis connection, and will be the only Redis connection receiving message from an external Redis server. You can also implement a different interface for your favorite message queue system and pass it in to the Messenger object to start receiving messages from that system.

The `MESSENGER` object is what drains all the messages from the `client` and will use a Ruby Regular Expression to match event patterns to figure out to which `Receiver` instance the message should be dispatched to, using Procs as callbacks.

The `REDIS` object is just a regular Redis object which we can use to publish messages.

Now in the `connection` action inside the `MainController` we have the following:

```rb
hijack do |websocket|
  receiver = MESSENGER.subscribe(/chatroom/)

  websocket.onopen do
    receiver.on_message { |message| websocket.send_data(message) }
    receiver.on_unsubscribe { REDIS.publish("chatroom", "You left the chat.") }
  end

  websocket.onmessage { |message| REDIS.publish("chatroom", message) }
  websocket.onclose { MESSENGER.unsubscribe(receiver) }
end
```

The `receiver` is the result of a new (local) subscription created by the `MESSENGER`. If an incoming event matches the `/chatroom/` pattern, then the `receiver`'s `on_message` callback will be called with the `message` passed in to it. A single `MESSENGER` can (and should) have multiple receivers, which is what happens as a new `receiver` is created for each websocket connection, sharing the same single Redis connnection through `MESSENGER`.

The `receiver.on_unsubscribe` callback can be defined to notifiy the `receiver` that it has been unsubscribed and will no longer receive messages from the `MESSENGER`. You'll want to make sure you unsubscribe all `receiver`s that are no longer used, otherwise this'll cause memory leaks and make your application run slow as the registry will fill up and increase look-up times.


## Creating your own Client

You can simply copy/paste/modify the `lib/msngr/clients/redis.rb` file and implement your own client. All you need to do is make sure the class implements the `on_message` method which should yield the name of the event and the message.

Example from `lib/msngr/clients/redis.rb`:

```rb
def on_message
  connection.psubscribe("*") do |on|
    on.pmessage { |_, event, message| yield event, message }
  end
end
```

This is the only required method to implement a compatible client.


## Try it out!

Be sure you have a Redis server running on your local machine, and do the following:

```
git clone https://github.com/meskyanichi/msngr.git
cd msngr
bundle
pry ./examples/redis.rb
```

This'll open an interactive shell with 4 receivers so you can play with the `r1`, `r2`, `r3`, `r4`, `redis`, and `messenger` variables.


### Contributing

Contributions are welcome, but please conform to these requirements:

- Ruby (MRI) 2.0+
- 100% Spec Coverage
  - Generated by when running the test suite
- 100% [Passing Specs]
  - Run test suite with `$ rspec spec`
- 4.0 [Code Climate Score]
  - Run `$ rubycritic lib` to generate the score locally and receive tips
  - No code smells
  - No duplication

To start contributing, fork the project, clone it, and install the development dependencies:

```
git clone git@github.com:USERNAME/msngr.git
cd msngr
bundle
```

Ensure that everything works:

```
rspec spec
rubycritic lib
```

To run the local documentation server:

```
yard server --reload
```

Create a new branch and start hacking:

```
git checkout -b my-contributions
```

Submit a pull request.


### Author / License

Released under the [MIT License] by [Michael van Rooijen].

[Michael van Rooijen]: https://twitter.com/meskyanichi
[HireFire]: http://hirefire.io
[Passing Specs]: https://travis-ci.org/meskyanichi/msngr
[Code Climate Score]: https://codeclimate.com/github/meskyanichi/msngr
[RubyDoc]: http://rubydoc.info/github/meskyanichi/msngr/master/frames
[MIT License]: https://github.com/meskyanichi/msngr/blob/master/LICENSE
[RubyGems.org]: https://rubygems.org/gems/msngr
[Tubesock]: https://github.com/ngauthier/tubesock
