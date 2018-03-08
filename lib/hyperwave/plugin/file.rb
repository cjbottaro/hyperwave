require "open-uri"
require "net/scp"
require "hyperwave/plugin"

module Hyperwave::Plugin::File

  def self.file(host, options = {})
    host.run_standard_command("file", options) do |options|
      dst = options[:dst]
      src = options[:src]
      data = open(src).read

      begin
        host.ssh.scp.upload!(StringIO.new(data), dst)
      rescue StandardError => e
        Result.new(error: "#{e.class}: #{e.message}")
      else
        Result.new
      end
    end
  end

  def file(options = {})
    Plugin::File.file(self, options)
  end

end
