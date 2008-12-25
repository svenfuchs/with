module With
  extend Sharing

  class Call
    attr_reader :name, :block
  
    def initialize(name, conditions = {}, &block)
      raise "need to provide a block" unless block
      
      @name = name
      @conditions = conditions
      @block = Proc.new {
        @_with_current_context = name
        instance_eval &block
      }
    end
    
    def applies?(context)
      names = context.parents.map(&:name) << context.name
      With.applies?(names, @conditions)
    end
    
    def to_proc
      @block
    end
    
    def call
      to_proc.call
    end
  end
end