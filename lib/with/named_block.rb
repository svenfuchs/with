module With
  class NamedBlock
    attr_reader :name, :block
  
    def initialize(name, &block)
      @name = name
      @block = block or raise "need to provide a block for an assertion"
    end
    
    def to_proc
      @block
    end
    
    def call
      to_proc.call
    end
  end
end