module Hyperwave
  class Result
    attr_accessor :stdout, :stderr, :code, :signal, :error

    def initialize
      @stdout = ""
      @stderr = ""
    end

    def success?
      @code == 0 && !@error
    end

    def failure?
      !success?
    end

  end
end
