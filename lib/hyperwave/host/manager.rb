require "thread"

module Hyperwave
  class Host
    module Manager
      extend(self)

      @lock = Mutex.new
      @hosts = Hash.new do |hosts, name|
        name = name.strip
        hosts[name] = Host.new(name)
      end

      def fetch(name)
        @lock.synchronize{ @hosts[name] }
      end

    end
  end
end
