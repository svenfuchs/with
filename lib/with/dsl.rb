module With
  module Dsl
    def self.included(base)
      base.send :include, Sharing
    end

    attr_accessor :parent

    def with(*names, &block)
      names << { :parent => self }
      Group.new(*names, &block)
    end

    def before(name = nil, &block)
      name ||= "before #{block.inspect}"
      preconditions << NamedBlock.new(name, &block)
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

    def children
      @children ||= []
    end

    def preconditions
      @preconditions ||= []
    end

    def assertions
      @assertions ||= []
    end

    module Sharing
      def share(*blocks, &block)
        name = blocks.shift
        blocks << block if block
        shared[name] = blocks
      end

      def shared
        @shared ||= {}
      end
    end
  end
end