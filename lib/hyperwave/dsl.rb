require "hyperwave/module/shell"

module Hyperwave
  module Dsl
    def hosts(name, &block)
      puts "hosts called"
      ["159.65.249.115"].each do |host|
        Net::SSH.start(host, "root") do |ssh|
          @ssh = ssh
          instance_eval(&block)
        end
      end
    end

    def run(mod, command, options = {})
      Hyperwave::Module::Shell.call(@ssh, command, options)
    end

  end
end
