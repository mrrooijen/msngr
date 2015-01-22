require "redis"
require "hiredis"
require "benchmark"

RUNS = 100_000

puts "Redis: Ruby Driver\n\n"

Benchmark.bm do |x|

  x.report "pub #{RUNS} messages" do
    redis = Redis.new
    RUNS.times do |n|
      redis.publish("chat", "John: Welcome to the chat!")
    end
  end

  x.report "pub + sub #{RUNS} messages" do
    pid1 = Process.fork do
      redis, i = Redis.new, 1000
      redis.psubscribe("*") do |on|
        on.pmessage do |_, __, ___|
          redis.punsubscribe("*") if (i+=1) == RUNS
        end
      end
    end

    pid2 = Process.fork do
      redis = Redis.new
      RUNS.times do |n|
        redis.publish("chat", "John: Welcome to the chat!")
      end
    end

    [pid1, pid2].each { |pid| Process.wait(pid) }
  end
end

puts
puts

puts "Redis: Hiredis Driver\n\n"

Benchmark.bm do |x|

  x.report "pub #{RUNS} messages" do
    redis = Redis.new(driver: :hiredis)
    RUNS.times do |n|
      redis.publish("chat", "John: Welcome to the chat!")
    end
  end

  x.report "pub + sub #{RUNS} messages" do
    pid1 = Process.fork do
      redis, i = Redis.new(driver: :hiredis), 1000
      redis.psubscribe("*") do |on|
        on.pmessage do |_, __, ___|
          redis.punsubscribe("*") if (i+=1) == RUNS
        end
      end
    end

    pid2 = Process.fork do
      redis = Redis.new(driver: :hiredis)
      RUNS.times do |n|
        redis.publish("chat", "John: Welcome to the chat!")
      end
    end

    [pid1, pid2].each { |pid| Process.wait(pid) }
  end
end
