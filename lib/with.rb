require 'with/node'
require 'with/sharing'
require 'with/context'
require 'with/call'

module With
  def self.included(base)
    base.send :extend, ClassMethods
  end

  module ClassMethods
    include Sharing
  
    def with_common(*names)
      @with_common ||= []
      @with_common += names
    end
    
    def describe(name, &block)
      context = Context.build(*with_common + [name], &block).first
      context.compile(self)
      context
    end
  end
  
  class << self
    def applies?(names, conditions)
      conditions[:in].nil? || names.include?(conditions[:in]) and
      conditions[:not_in].nil? || !names.include?(conditions[:not_in])
    end

    def aspects
      @@aspects ||= []
    end
    
    def aspect?(aspect)
      self.aspects.include?(aspect)
    end
  end
  
  # hmm, i can't see a way to solve nested it blocks rather than this because 
  # :it usually indicates an assertion and within assertions we want to be able 
  # to use instance vars as in:
  # it "articles should be new" do @article.new_record?.should == true end
  def it(name, &block)
    yield
  end
end