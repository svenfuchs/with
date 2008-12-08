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
        contexts = use_shared? ? shared_contexts : [to_context]
        contexts.each do |context|
          context.append_children children.map{|c| c.expand }.flatten
        end
      end

      def use_shared?
        names.first.is_a?(Symbol)
      end

      def shared_group(name)
        shared[name] || parent && parent.shared_group(name) or raise "could not find shared context #{name.inspect}"
      end

      def shared_contexts
        names.map do |name|
          shared_group(name).map do |group|
            group.to_context(@action, preconditions, assertions)
          end
        end.flatten
      end

      def to_context(action = nil, preconditions = [], assertions = [])
        action ||= @action
        # raise if there's more than one name?
        # or maybe better have separate attributes for name and shared_names?
        Context.new(names.first, action, self.preconditions + preconditions, self.assertions + assertions)
      end

      def add_child(*names, &block)
        child = Group.new(*names, &block)
        child.parent = self
        children << child
        child
      end

      def method_missing(method_name, *args, &block)
        description = method_name
        description = "#{description}_#{args.map(&:inspect).join('_')}".to_sym unless args.empty?

        assertion description do
          send method_name, *args, &block
        end
      end
  end
end