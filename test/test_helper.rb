$:.unshift File.dirname(__FILE__) + '/../lib2/'
require 'with'

module GroupSetup
  include With
  
  def setup_example_group
    Group.new 'root' do
      # unknown_assertion :foo, :bar
      action { :action_on_group }
      
      before :common_precondition do end
        
      with :context do
        action { :action_on_context }
        
        before :shared_precondition do end
        
        it 'does something' do 
          it 'does something nested' do
            before :unique_precondition do end
          end
        end
        
        it 'does something in nested_context', :with => :nested_context do end
      end
      
      share :nested_context,
        lambda { before :precondition_in_nested_context_1 do end },
        lambda { before :precondition_in_nested_context_2 do end }
    end
  end
end

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
