require "thread"

require "hyperwave/host"

module Hyperwave
  class Run

    attr_reader :hosts, :block

    def initialize(hosts, &block)
      @hosts = [hosts].flatten.map{ |host| Host.fetch(host) }
      @block = block

      @lock = Mutex.new
      @cond = ConditionVariable.new

      # Yeah, I'm using the same lock for both resources. I don't care.
      # I don't think there is a correctness issue (no deadlocks), and the
      # performance hit is negligable.

      @wait_count = 0
      @print_count = 0

      # None of this stuff is reentrant, but that's fine because nothing can
      # cause recursive calls of #wait or #print_once. Neither are calling any
      # complex functions or blocks or anything.
    end

    def call
      hosts.map{ |host| start_host_thread(host) }.each(&:join)
    end

    # Print once per top level command.
    # All hosts have to call this before it's reset. You can't have 3/5 hosts
    # call it and expect it work properly.
    def print_once(msg)
      @lock.synchronize do
        print "#{msg}\n" if @print_count == 0
        @print_count += 1
        @print_count = 0 if @print_count == hosts.size
      end
    end

    # Same deal, all hosts have to call this before it is reset and we can
    # go to the next command. It is formally a "barrier" since individual
    # threads block until all threads have reported in.
    def wait
      @lock.synchronize do
        @wait_count += 1
        if @wait_count == hosts.size
          @wait_count = 0
          @cond.broadcast
        else
          @cond.wait(@lock)
        end
      end
    end

  private

    def start_host_thread(host)
      Thread.new{ host.start_run(self, &block) }
    end

  end
end
