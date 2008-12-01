require 'with/dsl'

module With
  class Group
    include Dsl

    attr_reader :names

    def initialize(*args, &block)
      options = args.last.is_a?(Hash) ? args.pop : {}
      @parent = options[:parent]
      @parent.children << self if @parent
      @names = args

      instance_eval &block if block
    end

    def compile(target)
      expand.first.leafs.each { |leaf| define_test_method(target, leaf) }
    end

    protected

      def expand
        names.map do |name|
          shared_blocks = find_shared(name) || [nil]
          shared_blocks.map do |shared|
            context = Context.new(name, @action, preconditions.dup, assertions.dup, &shared)
            children.each { |child| context.add_children *child.expand }
            context
          end
        end.flatten
      end

      def find_shared(name)
        shared[name] || parent && parent.find_shared(name)
      end

      def define_test_method(target, context)
        action, preconditions, assertions = *context.calls
        method_name = generate_test_method_name(context)

        target.send :define_method, method_name, &lambda {
          preconditions.map { |precondition| instance_eval &precondition }
          instance_eval &action
          assertions.map { |assertion| instance_eval &assertion }
        }
      end

      def generate_test_method_name(context)
        contexts = context.self_and_parents
        name = "test_<#{context.object_id}>_#{contexts.shift.name}_"
        name += contexts.map { |c| "with_#{c.name}" }.join('_and_')
        name.gsub(/[\W ]/, '_').gsub('__', '_')
      end
  end
end