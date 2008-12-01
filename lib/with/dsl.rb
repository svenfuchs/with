module With
  module Dsl    
    attr_reader :children
    attr_accessor :parent

    attr_reader :preconditions
    attr_reader :assertions
  
    def with(*names, &block)
      names << { :parent => self }
      Group.new(*names, &block)
    end
    
    def before(name = nil, &block)
      name ||= "before #{block.inspect}"
      @preconditions << NamedBlock.new(name, &block)
    end
  
    def action(name = nil, &block)
      name ||= "action #{block.inspect}"
      @action = NamedBlock.new(name, &block)
    end
  
    def assertion(name = nil, options = {}, &block)
      group = options[:with] ? with(*options[:with]) : self
      group.assertions << NamedBlock.new(name, &block)
    end
    alias :it :assertion
  
    def share(*blocks, &block)
      name = blocks.shift
      blocks << block if block
      @shared[name] = blocks
    end
  end
end