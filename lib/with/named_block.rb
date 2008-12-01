module With
  class NamedBlock
    attr_reader :name, :block
  
    def initialize(name, &block)
      @name = name
      @block = block or raise "need to provide a block for an assertion"
    end
  
    def call
      @block.call
      name
    end
  end
end