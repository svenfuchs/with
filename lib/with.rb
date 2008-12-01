require 'with/context'
require 'with/group'
require 'with/named_block'

module With
  def describe(name, &block)
    group = Group.new name, &block
    group.compile(self)
    group
  end
end