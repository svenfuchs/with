module With
  class Context
    attr_accessor :parent
    attr_reader :name, :children, :action, :assertions, :preconditions

    def initialize(name, action, preconditions, assertions, &block)
      @name, @action, @preconditions, @assertions = name, action, [], []
      @children = []

      instance_eval &block if block

      @preconditions += preconditions
      @assertions += assertions
    end

    def calls
      [find_action, collect_preconditions, collect_assertions]
    end

    def parents
      parent ? parent.parents + [parent] : []
    end

    def leafs
      return [self] if children.empty?
      children.map { |child| child.leafs }.flatten
    end

    def add_children(*children)
      children.each do |child|
        child.parent = self
        @children << child
      end
    end

    def append_children(children)
      leafs.each { |leaf| leaf.add_children *children }
    end

    def compile(target)
      leafs.each { |leaf| define_test_method(target, leaf) }
    end

    protected

      def find_action
        @action || parent && parent.find_action
      end

      def collect_preconditions
        (parent ? parent.collect_preconditions : []) + @preconditions
      end

      def collect_assertions
        (parent ? parent.collect_assertions : []) + @assertions
      end

      def define_test_method(target, context)
        action, preconditions, assertions = *context.calls
        method_name = generate_test_method_name(context, assertions)

        target.send :define_method, method_name, &lambda {
          preconditions.map { |precondition| instance_eval &precondition }
          instance_eval &action if action
          assertions.map { |assertion| instance_eval &assertion }
        }
      end

      # TODO urghs.
      def generate_test_method_name(context, assertions)
        contexts = context.parents << context
        name = "test_#{context.object_id}_#{contexts.shift.name}_"
        name += contexts.map { |c| "with_#{c.name}_" }.join('and_')
        name += assertions.map { |a| "it_#{a.name}_" }.join('and_')
        name.gsub(/ /, '_').gsub('it_it_', 'it_').gsub('__', '_').gsub(/_$/, '')
      end
  end
end