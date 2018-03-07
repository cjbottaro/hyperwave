require "net/ssh"
require "yaml"

require "hyperwave/version"
require "hyperwave/host"

class Barrier
  def initialize(size)
    @size = size
    @count = 0
    @puts_count = 0
    @puts_lock = Mutex.new
    @lock = Mutex.new
    @cond = ConditionVariable.new
  end

  def puts(message)
    @puts_lock.synchronize do
      Kernel.puts message if @puts_count == 0
      @puts_count += 1
      @puts_count = 0 if @puts_count == @size
    end
  end

  def done
    @lock.synchronize do
      @count += 1
      @count = 0 if @count == @size
      @cond.broadcast
    end
  end

  def wait
    @lock.synchronize do
      @cond.wait(@lock) while @count > 0
    end
  end
end

module Hyperwave

  def self.each_host(hosts, &block)
    hosts = [hosts].flatten
    barrier = Barrier.new(hosts.length)
    threads = hosts.map{ |host| Thread.new{ Hyperwave::Host.new(host, barrier).call(&block)} }
    threads.map(&:join)
  end

end
