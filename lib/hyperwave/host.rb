require "net/ssh"
require "hyperwave/module/shell"

module Hyperwave
  class Host

    def initialize(host)
      @host = host
    end

    def call(&block)
      Net::SSH.start(@host, "root") do |ssh|
        @ssh = ssh
        block.call(self)
      end
    end

    def shell(cmd, options)
      Hyperwave::Module::Shell.call(@ssh, cmd, options)
    end

  end
end
