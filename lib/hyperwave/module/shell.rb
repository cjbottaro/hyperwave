require "hyperwave/result"

module Hyperwave
  module Module
    module Shell

      def self.shell(host, options = {})
        host.run_standard_command("shell", options) do |options|
          sh  = options[:sh]
          cmd = options[:cmd]
          dir = options[:chdir]
          cmd = "cd #{dir} && #{cmd}" if dir
          cmd = cmd.gsub("'", "'\\\\''") # I hate life.

          result = Hyperwave::Result.new

          channel = host.ssh.open_channel do |ch|
            ch.exec("#{sh} -c '#{cmd}'") do |ch, success|
              unless success
                result.error = "couldn't execute command (ssh.channel.exec)"
              end

              ch.on_data do |ch,data|
                result.stdout += data
              end

              ch.on_extended_data do |ch,type,data|
                result.stderr += data
              end

              ch.on_request("exit-status") do |ch,data|
                result.code = data.read_long
              end

              ch.on_request("exit-signal") do |ch, data|
                result.signal = data.read_long
              end
            end
          end

          channel.wait

          result.stdout.chomp!
          result.stderr.chomp!

          result
        end
      end

      def shell(options = {})
        Hyperwave::Module::Shell.shell(self, options)
      end

    end
  end
end
