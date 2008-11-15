module IQ::Tests::ACL::Factory
  
  # Recorder class useful for recording method calls and checking their
  # results. This is especially useful for checking that blocks get called.
  class Recorder
    def calls
      @calls ||= []
    end

    def [](sym)
      calls.find { |call| call.method.eql?(sym) } || Call.new(nil, nil, nil)
    end

    def method_missing(sym, *args, &block)
      calls << Call.new(sym, args, block)
      self
    end
    
    class Call
      attr_reader :method, :args, :block
      def initialize(sym, args, block)
        @method, @args, @block = sym, args, block
      end
    end
  end
  
  def self.recorder_instance
    Recorder.new
  end
  
  # Basic
  # -----
  def self.new_basic(*args)
    IQ::ACL::Basic.new(*args)
  end
  
end