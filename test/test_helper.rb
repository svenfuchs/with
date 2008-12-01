$:.unshift File.dirname(__FILE__) + '/../lib/'
require 'with'


class Test::Unit::TestCase
  def assert_assertions(expected, context)
    assert_equal expected, context.send(:collect_assertions).map(&:name)
  end
end

class Symbol
  def to_proc
    Proc.new { |*args| args.shift.__send__(self, *args) }
  end
end
