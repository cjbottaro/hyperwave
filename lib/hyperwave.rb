require "hyperwave/version"
require "hyperwave/run"

module Hyperwave
  extend(self)

  def each_host(hosts, &block)
    Run.new(hosts, &block).call
  end

end
