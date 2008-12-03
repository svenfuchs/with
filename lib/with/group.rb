module With
  class Group
    include Sharing
    
    attr_accessor :parent
    attr_reader :names

    def initialize(*names, &block)
      @names = names
      instance_eval &block if block
    end

    def with(*names, &block)
      add_child(*names, &block)
    end
    
    def assertion(name = nil, options = {}, &block)
      # options = names.last.is_a?(Hash) ? names.pop : {}
      group = options[:with] ? with(*options[:with]) : self
      group.assertions << NamedBlock.new(name, &block)
    end
    alias :it :assertion

    def before(name = nil, &block)
      name ||= "before #{block.inspect}"
      preconditions << NamedBlock.new(name, &block)
    end

    def action(name = nil, &block)
      name ||= "action #{block.inspect}"
      @action = NamedBlock.new(name, &block)
    end

    def children
      @children ||= []
    end

    def preconditions
      @preconditions ||= []
    end

    def assertions
      @assertions ||= []
    end

    def compile(target)
      expand.first.compile(target)
    end
    
    protected

      def expand
        names.map do |name|
          contexts_for(name).each do |context|
            context.append_children children.map{|c| c.expand }.flatten
          end
        end.flatten
      end
      
      def contexts_for(name)
        # TODO refactor this mess
        if shared_groups = find_shared(name)
          shared_groups.map do |g|
            context = Context.new g.names.first, nil,
                                  g.preconditions + preconditions.dup,
                                  g.assertions += assertions.dup
          end
        else
          [Context.new(name, @action, preconditions.dup, assertions.dup)]
        end
      end

      def find_shared(name)
        shared[name] || parent && parent.find_shared(name)
      end
    
      def add_child(*names, &block)
        child = Group.new(*names, &block)
        child.parent = self
        children << child
        child
      end
    
      def method_missing(name, *args, &block)
        assertion name do
          send name, *args, &block
        end
      end
  end
end