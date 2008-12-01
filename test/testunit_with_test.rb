$:.unshift File.dirname(__FILE__) + '/../lib/'
require 'with'

class TestUnitWithTest < Test::Unit::TestCase
  extend With
  
  describe 'foo' do
    action { :'called action!' }
    
    with :'context 1', :'context 2' do
      it :'assertion 1', :with => :'context 3' do
        :'called assertion 1'
      end
    end
    
    share :'context 1' do 
      before :'precondition 1' do
        :'called precondition 1'
      end
    end
    
    share :'context 2' do 
      before :'precondition 2' do
        :'called precondition 2'
      end
    end
  end
  
  @@tests_defined = instance_methods.grep(/^test_/)

  def test_with_defined_two_tests
    names = [ "test_foo_with_context_1_and_with_context_3", 
              "test_foo_with_context_2_and_with_context_3" ]
    assert_equal names, @@tests_defined
  end
end