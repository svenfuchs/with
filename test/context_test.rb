require File.dirname(__FILE__) + '/test_helper'

class GroupExpandedTest < Test::Unit::TestCase
  include GroupSetup
  
  def setup
    @group = setup_example_group
    @expanded = @group.send :expand
  end
  
  def test_expanded_structure
    # there's one root
    assert_equal 1, @expanded.size
    @root = @expanded[0]
    assert_equal 'root', @root.name
    
    # root has one child: context
    assert_equal 1, @root.children.size
    @context = @root.children[0]
    assert_equal :context, @context.name
    
    # context has three children: does_something and 2x nested_context
    assert_equal 3, @context.children.size
    @does_something = @context.children[0]
    @nested_context_1 = @context.children[1]
    @nested_context_2 = @context.children[1]
    
    assert_equal 'does something', @does_something.name
    assert_equal :nested_context, @nested_context_1.name
    assert_equal :nested_context, @nested_context_2.name
    
    # does_something has one child: does_something_nested
    assert_equal 1, @does_something.children.size
    @does_something_nested = @does_something.children[0]
    assert_equal 'does something nested', @does_something_nested.name
    
    # nested_context_1 and nested_context_2 have each one child: does_something_in_nested_context
    assert_equal 1, @nested_context_1.children.size
    assert_equal 1, @nested_context_2.children.size
    @does_something_in_nested_context = @nested_context_1.children[0]
    
    assert_equal 'does something in nested_context', @does_something_in_nested_context.name
    
    # it's actually the same object instance. not sure if that could cause any trouble:
    assert_equal @nested_context_1.children[0], @nested_context_2.children[0]
  end
  
  def test_expanded_leafs
    leafs = @expanded.first.leafs

    expected = [ "does something nested",
                 "does something in nested_context", 
                 "does something in nested_context" ]
    assert_equal expected, leafs.map(&:name)
    
    expected = [ ["root", :context, "does something", "does something nested"],
                 ["root", :context, :nested_context, "does something in nested_context"],
                 ["root", :context, :nested_context, "does something in nested_context"] ]
    result = leafs.map {|leaf| leaf.parents.map(&:name) << leaf.name }
    assert_equal expected, result
  end
end

