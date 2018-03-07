require "net/ssh"
require "colorized_string"
require "hyperwave/host/manager"
require "hyperwave/module/shell"
require "hyperwave/module/file"

module Hyperwave
  class Host

    include Hyperwave::Module::Shell
    include Hyperwave::Module::File

    attr_reader :ssh, :run

    def self.fetch(host)
      Manager.fetch(host)
    end

    def initialize(host)
      @host = host
    end

    def start_run(run, &block)
      @run = run
      ensure_clean_ssh_connection
      block.call(self)
    ensure
      @run = nil
    end

    DEFAULT_COMMAND_OPTIONS = {
      sh: "/bin/sh",
      change: true
    }

    def run_standard_command(name, options, &block)
      options = DEFAULT_COMMAND_OPTIONS.merge(options)

      start_top_level_command do
        print_once(name, options[:desc])

        if guarded?(options)
          report(:ok)
          return
        end

        result = block.call(options)

        if result.failure?
          report(:error, result.stderr)
        elsif options[:change]
          report(:change)
        else
          report(:ok)
        end

        result
      end
    end

  private

    def stack
      Thread.current["hyperwave/stack"] ||= 0
      Thread.current["hyperwave/stack"]
    end

    def stack_incr
      Thread.current["hyperwave/stack"] = stack + 1
    end

    def stack_decr
      Thread.current["hyperwave/stack"] = stack - 1
    end

    def top_level?
      stack == 1
    end

    def ensure_clean_ssh_connection
      @ssh = Net::SSH.start(@host, "root") if !@ssh || @ssh.closed?
      @ssh.channels.each{ |ch| @ssh.cleanup_channl(ch) }
    end

    def start_top_level_command(&block)
      stack_incr
      begin
        block.call
      ensure
        run.wait if top_level?
        stack_decr
      end
    end

    def print_once(tag, desc)
      return unless top_level?
      msg = ColorizedString.new("[#{tag}]").blue + " #{desc}"
      run.print_once(msg)
    end

    def report(status, extra = nil)
      return unless top_level?

      msg = case status
      when :ok
        ColorizedString.new("ok").green
      when :changed
        ColorizedString.new("ok").yellow
      when :error
        ColorizedString.new("error").red
      end
      msg += " - #{extra}" if extra

      printf "  %-16s : %s\n" % [@host, msg]
    end

    # Returns true if guard should prevent execution of command.
    # if: true  -> return false (run  command)
    # if: false -> return true  (skip command)
    # unless: true  -> return true  (skip command)
    # unless: false -> return false (run command)
    def guarded?(options)
      guard = options[:if] || options[:unless]

      case guard
      when nil
        false
      when true, false
        !options[:if]
      when String
        result = shell(options.merge(cmd: guard, if: nil, unless: nil))
        if options[:if]
          result.failure?
        else
          result.success?
        end
      end
    end

  end
end
