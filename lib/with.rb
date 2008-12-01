require 'with/context'
require 'with/group'
require 'with/named_block'

module With
  def self.included(base)
    base.send :include, Dsl::Sharing
  end

  def describe(name, &block)
    group = Group.new name, &block
    group.compile(self)
    group
  end
end