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
        method_name = generate_test_method_name(context)

        target.send :define_method, method_name, &lambda {
          preconditions.map { |precondition| puts precondition.name; instance_eval &precondition }
          instance_eval &action if action
          assertions.map { |assertion| puts assertion.name; instance_eval &assertion }
        }
      end

      def generate_test_method_name(context)
        contexts = context.parents << context
        name = "test_<#{context.object_id}>_#{contexts.shift.name}_"
        name += contexts.map { |c| "with_#{c.name}" }.join('_and_')
        name.gsub(/[\W ]/, '_').gsub('__', '_')
      end
  end
end