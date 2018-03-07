require "open-uri"
require "net/scp"

module Hyperwave::Module::File

  def self.file(host, options = {})
    host.run_standard_command("file", options) do |options|
      dst = options[:dst]
      src = options[:src]
      data = open(src).read

      scp = Net::SCP.new(host.ssh)
      scp.upload!(StringIO.new(data), dest)

      result = Hyperwave::Result.new
      result.code = 0
    end
  end

  def file(options = {})
    Hyperwave::Module::File.file(self, options)
  end

end
