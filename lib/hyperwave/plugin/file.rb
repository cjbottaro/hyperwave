require "open-uri"
require "net/scp"
require "hyperwave/plugin"

module Hyperwave::Plugin::File

  def self.file(host, options = {})
    host.run_top_level_command("file", options) do |options|
      dst = options[:dst]
      src = options[:src]
      data = open(src).read

      begin
        host.ssh.scp.upload!(StringIO.new(data), dst)
      rescue StandardError => e
        Hyperwave::Result.new(error: "#{e.class}: #{e.message}")
      else
        Hyperwave::Result.new
      end
    end
  end

  def file(options = {})
    Hyperwave::Plugin::File.file(self, options)
  end

end
