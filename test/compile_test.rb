require File.dirname(__FILE__) + '/test_helper'

class TestUnitWithTest < Test::Unit::TestCase
  include With

  share :'context 2' do
    before :'precondition 2' do
      :'called precondition 2'
    end
  end
  
  describe 'foo' do
    action { :'called action!' }

    with :'context 1', :'context 2' do
      it 'does something', :with => :'context 3' do
        :'called assertion 1'
      end
    end

    share :'context 1' do
      before :'precondition 1' do
        :'called precondition 1'
      end
    end

    share :'context 3' do
      before :'precondition 3' do
        :'called precondition 3'
      end
    end
  end

  @@tests_defined = instance_methods.grep(/^test_/).map{|name| name.gsub(/test_[\d]*/, 'test')}.sort

  def test_with_defined_two_tests
    names = [ "test_foo_with_context_1_and_with_context_3",
              "test_foo_with_context_2_and_with_context_3" ]
    assert_equal names, @@tests_defined
  end
end