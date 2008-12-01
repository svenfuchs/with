require 'with/context'
require 'with/group'
require 'with/named_block'

module With
  def self.included(base)
    base.send :extend, ClassMethods
  end
  
  module ClassMethods
    include Dsl::Sharing
    
    def inherited(base)
      base.instance_variable_set(:@shared, @shared)
    end
    
    def describe(name, &block)
      group = Group.new name, &block
      shared.each {|name, blocks| group.share(name, *blocks) }
      group.compile(self)
      group
    end
  end
end