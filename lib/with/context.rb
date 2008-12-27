module With
  class Context < Node
    class << self
      def build(*names, &block)
        context = new
        
        names.each do |names| 
          children = Array(names).map do |name| 
            name.is_a?(Symbol) ? With.shared(name) : new(name)
          end.flatten
          context.append_children children
        end
        
        context.children.each do |child|
          child.parent = nil
          child.leafs.each { |leaf| leaf.instance_eval(&block) } if block
        end
      end
    end
    
    def initialize(name = nil, &block)
      super(name)
      instance_eval &block if block
    end
    
    def with(*names, &block)
      options = names.last.is_a?(Hash) ? names.pop : {}
      Context.build(*names, &block).each do |child|
        add_child child
        child.filter(options) unless options.empty?
      end
    end
    
    [:before, :action, :assertion, :after].each do |name|
      class_eval <<-code
        def #{name}(name = nil, options = {}, &block)
          contexts = options[:with] ? with(*options.delete(:with)) : [self]
          contexts.each {|c| c.calls(:#{name}) << Call.new(name, options, &block) }
        end
      code
    end
    alias :expect :before
    alias :it :assertion

    def compile(target)
      leafs.each { |leaf| define_test_method(target, leaf) }
    end
    
    protected

      def method_missing(method_name, *args, &block)
        options = {}
        if args.last.is_a?(Hash) and [:in, :not_in].select{|key| args.last.has_key?(key) }
          [:with, :in, :not_in].each { |key| options[key] = args.last.delete(key) }
          args.pop if args.last.empty?
        end
        assertion ([method_name] << args.map(&:inspect)).join('_'), options do
          send method_name, *args, &block
        end
      end

      def define_test_method(target, context)
        method_name = generate_test_method_name(context)
        target.send :define_method, method_name, &lambda {
          @_with_contexts = (context.parents << context).map(&:name)
          [:before, :action, :assertion, :after].each do |stage|
            @_with_current_stage = stage
            context.collect(stage).map { |call| instance_eval &call }
          end
        }
      end

      # TODO urghs. super ugly and doesn't even really work well.
      # Need some better ideas for generating readable method names.
      # Maybe even play with method names containing \n characters?
      def generate_test_method_name(context)
        contexts = context.parents << context
        assertions = context.calls(:assertion)
        
        name = "test_##{context.object_id}\n#{contexts.shift.name}"
        name += contexts.map { |c| "\nwith #{c.name} " }.join("and")
        name += assertions.map { |a| "\nit #{a.name} " }.join("and")
        name.gsub('_', ' ').gsub('  ', ' ').gsub('it it', 'it') #.gsub('__', '_').gsub('__', '_').gsub(/"|(_$)/, '')
      end
  end
end