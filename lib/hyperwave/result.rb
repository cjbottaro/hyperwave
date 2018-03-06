module Hyperwave
  class Result
    attr_accessor :stdout, :stderr, :code, :signal

    def initialize
      @stdout = ""
      @stderr = ""
    end

  end
end
