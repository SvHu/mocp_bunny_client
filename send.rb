#!/usr/bin/env ruby
# encoding: utf-8
require "bundler/setup"

require "bunny"
require "thread"
require "securerandom"
require 'yaml'

config_file = File.expand_path("config.yml", __dir__)
attributes = YAML.load_file(config_file)

conn = Bunny.new(:host => attributes[:hostname], :user => attributes[:rabbit_user], :password => attributes[:rabbit_password], 
  :automatically_recover => false)
conn.start

ch = conn.create_channel

class MusicClient
  attr_reader :reply_queue
  attr_accessor :response, :call_id
  attr_reader :lock, :condition

  def initialize(ch, server_queue)
    @ch             = ch
    @x              = ch.default_exchange

    @server_queue   = server_queue
    @reply_queue    = ch.queue("", :exclusive => true)

    @lock      = Mutex.new
    @condition = ConditionVariable.new
    that       = self

    @reply_queue.subscribe do |delivery_info, properties, payload|
      if properties[:correlation_id] == that.call_id
        that.response = payload.to_s
        that.lock.synchronize{that.condition.signal}
      end
    end
  end

  def call(request)
    self.call_id = SecureRandom.uuid

    @x.publish(request.to_s,
      :routing_key    => @server_queue,
      :correlation_id => call_id,
      :reply_to       => @reply_queue.name)

    lock.synchronize{condition.wait(lock)}
    puts response
    response
  end
end

client   = MusicClient.new(ch, "musicbox")
request = ARGF.argv
puts " [x] Sending #{request.to_s}"
response = client.call(request)

puts " [.] Response: #{response}"
ch.close
conn.close