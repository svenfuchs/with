require 'with/sharing'
require 'with/context'
require 'with/group'
require 'with/named_block'

module With
  def self.included(base)
    base.send :extend, ClassMethods
  end

  module ClassMethods
    include Sharing

    def inherited(base)
      base.instance_variable_set(:@shared, @shared)
    end

    def describe(name, &block)
      group = Group.new name, &block
      shared.each {|name, groups| group.share(name, *groups) }
      group.compile(self)
      group
    end
  end

  def it(name, &block)
    yield
  end
end