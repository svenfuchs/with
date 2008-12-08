require File.dirname(__FILE__) + '/test_helper'

class GroupTest < Test::Unit::TestCase
  include GroupSetup

  def setup
    @group = setup_example_group
  end

  def test_with_creates_a_child_group
    # creates a child: context
    assert_equal 1, @group.children.size
    context = @group.children[0]
    assert context.is_a?(Group)
    assert_equal [:context], context.names

    # context has two children: something and nested_context
    assert_equal 2, context.children.size
    something = context.children[0]
    nested_context = context.children[1]

    assert something.is_a?(Group)
    assert nested_context.is_a?(Group)

    assert_equal ['something'], something.names
    assert_equal [:nested_context], nested_context.names

    # something has one child: something_nested
    assert_equal 1, something.children.size
    something_nested = something.children[0]
    assert something_nested.is_a?(Group)
    assert_equal ['something nested'], something_nested.names

    # nested_context has no children: something_in_nested_context
    assert_equal 0, nested_context.children.size
  end

  def test_sets_action_on_current_group
    context = @group.children[0]

    assert_equal :action_on_group, @group.instance_variable_get(:@action).call
    assert_equal :action_on_context, context.instance_variable_get(:@action).call
  end

  def test_records_preconditions_on_current_group
    context = @group.children[0]
    something_nested = context.children[0].children[0]

    assert_equal [:common_precondition], @group.preconditions.map(&:name)
    assert_equal [:shared_precondition], context.preconditions.map(&:name)
    assert_equal [:unique_precondition], something_nested.preconditions.map(&:name)
  end

  def test_records_calls_to_unknown_methods_as_assertions
    assert_equal :defined_assertion, @group.assertions[0].name
  end
end