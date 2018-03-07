require "net/ssh"
require "yaml"

require "hyperwave/version"
require "hyperwave/run"

module Hyperwave

  def self.each_host(hosts, &block)
    Run.new(hosts, &block).call
  end

end
