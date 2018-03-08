module Hyperwave
  class Result
    attr_accessor :stdout, :stderr, :code, :signal, :error

    def initialize(attrs = {})
      @code   = attrs[:code]   || 0
      @stdout = attrs[:stdout] || ""
      @stderr = attrs[:stderr] || ""
      @signal = attrs[:signal]
      @error  = attrs[:error]
    end

    def success?
      @code == 0 && !@error
    end

    def failure?
      !success?
    end

    def error
      if success?
        nil
      else
        @error || stderr
      end
    end

  end
end
