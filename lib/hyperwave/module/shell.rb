require "hyperwave/result"

module Hyperwave
  module Module
    module Shell
      extend(self)

      DEFAULT_OPTIONS = {
        binary: "/bin/sh",
        chdir: nil,
        unless: true
      }

      def call(ssh, cmd, options = {})
        options = DEFAULT_OPTIONS.merge(options)
        puts options.inspect

        command = [
          options[:chdir] && "cd #{options[:chdir]}",
          cmd
        ].compact.join(" && ")

        binary = options[:binary]

        result = Hyperwave::Result.new

        case options[:unless]
        when Proc
          return result unless options[:unless].call
        when false, nil
          return result
        end

        puts "RUNNING: #{cmd}"

        channel = ssh.open_channel do |ch|
          ch.exec("#{binary} -c '#{command}'") do |ch, success|
            unless success
              abort "FAILED: couldn't execute command (ssh.channel.exec)"
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

        puts result.inspect

        result
      end

    end
  end
end
