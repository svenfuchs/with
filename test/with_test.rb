$:.unshift File.dirname(__FILE__) + '/../lib/'
require 'with'

# when expanded it sets up the following context tree:
#
# context 1.1
#   shared assertion 1.1.1
#   shared assertion 1.1.2
#   context 2
#     shared assertion 2
#     assertion 2.3
#     context 3.1
#       shared assertion 3.1
#       assertion 2.1
#     context 3.2
#       shared assertion 3.2
#       assertion 2.1
#     context 4
#       shared assertion 4.1
#       assertion 2.2
#     context 4
#       shared assertion 4.2
#       assertion 2.2
# context 1.2
#   shared assertion 1.2
#   context 2
#     shared assertion 2
#     assertion 2.3
#     context 3.1
#       shared assertion 3.1
#       assertion 2.1
#     context 3.2
#       shared assertion 3.2
#       assertion 2.1
#     context 4
#       shared assertion 4.1
#       assertion 2.2
#     context 4
#       shared assertion 4.2
#       assertion 2.2

class WithTest < Test::Unit::TestCase
  include With
  
  def setup
    @group = describe 'main' do
      action { :'called action!' }
      
      with :'context 1.1', :'context 1.2' do
        with :'context 2' do
          it :'assertion 2.1', :with => [:'context 3.1', :'context 3.2'] do
            :'called assertion 2.1'
          end
          
          it :'assertion 2.2', :with => :'context 4' do
            :'called assertion 2.2'
          end
          
          it :'assertion 2.3' do
            :'called assertion 2.3'
          end
        end
      end
      
      share :'context 1.1' do 
        before :'precondition 1.1' do
          :'called precondition 1.1'
        end
        
        it :'shared assertion 1.1.1' do
          :'called shared assertion 1.1.1'
        end
        
        it :'shared assertion 1.1.2' do
          :'called shared assertion 1.1.2'
        end 
      end
      
      share :'context 1.2' do 
        before :'precondition 1.2' do
          :'called precondition 1.2'
        end
        
        it :'shared assertion 1.2' do
          :'called shared assertion 1.2'
        end 
      end
      
      share :'context 2'   do 
        before :'precondition 2' do
          :'called precondition 2'
        end
        
        it :'shared assertion 2' do
          :'called shared assertion 2'
        end 
      end
      
      share :'context 3.1' do 
        before :'precondition 3.1' do
          :'called precondition 3.1'
        end
        
        it :'shared assertion 3.1' do
          :'called shared assertion 3.1'
        end 
      end
      
      share :'context 3.2' do 
        before :'precondition 3.2' do
          :'called precondition 3.2'
        end
        
        it :'shared assertion 3.2' do
          :'called shared assertion 3.2'
        end
      end
      
      share :'context 4', 
        lambda { 
          before :'precondition 4.1' do
            :'called precondition 4.1'
          end
        
          it :'shared assertion 4.1' do 
            :'called shared assertion 4.1' 
          end 
        },
        lambda { 
          before :'precondition 4.2' do
            :'called precondition 4.2'
          end
        
          it :'shared assertion 4.2' do 
            :'called shared assertion 4.2' 
          end 
        }
    end
  end
  
  def test_context_group_tree
    assert_equal ['main'], @group.names
    assert_equal [:'context 1.1', :'context 1.2'], @group.children[0].names
    assert_equal [:'context 2'], @group.children[0].children[0].names
    assert_equal [:'context 3.1', :'context 3.2'], @group.children[0].children[0].children[0].names
    assert_equal [:'context 4'], @group.children[0].children[0].children[1].names
    assert_equal :'assertion 2.1', @group.children[0].children[0].children[0].assertions.first.name
    assert_equal :'assertion 2.2', @group.children[0].children[0].children[1].assertions.first.name
    assert_equal :'assertion 2.3', @group.children[0].children[0].assertions.first.name
  end
  
  def test_context_group_exapand
    root = @group.expand.first
  
    expected = [:'context 1.1', :'context 1.2']
    assert_equal expected, root.children.map {|child| child.name }
    
    expected = [:'context 2']
    assert_equal expected, root.children[0].children.map {|child| child.name }
    
    expected = [:"context 3.1", :"context 3.2", :"context 4", :"context 4"]
    assert_equal expected, root.children[0].children[0].children.map {|child| child.name }
    
    expected = [:'context 2']
    assert_equal expected, root.children[1].children.map {|child| child.name }
    
    expected = [:"context 3.1", :"context 3.2", :"context 4", :"context 4"]
    assert_equal expected, root.children[1].children[0].children.map {|child| child.name }
  end
  
  def test_context_group_exapanded_collect_assertations
    root = @group.expand.first
    
    expected = [:'shared assertion 1.1.1', :'shared assertion 1.1.2']
    assert_equal expected, root.children[0].collect_assertions.map {|a| a.name }
    
    expected = [:"shared assertion 1.1.1", :"shared assertion 1.1.2", 
                :"shared assertion 2", :"assertion 2.3"]
    assert_equal expected, root.children[0].children[0].collect_assertions.map {|a| a.name }

    expected = [:"shared assertion 1.1.1", :"shared assertion 1.1.2", 
                :"shared assertion 2", :"assertion 2.3", 
                :"shared assertion 3.1", :"assertion 2.1"]
    assert_equal expected, root.children[0].children[0].children[0].collect_assertions.map {|a| a.name }

    expected = [:"shared assertion 1.1.1", :"shared assertion 1.1.2", 
                :"shared assertion 2", :"assertion 2.3", 
                :"shared assertion 3.2", :"assertion 2.1"]
    assert_equal expected, root.children[0].children[0].children[1].collect_assertions.map {|a| a.name }

    expected = [:"shared assertion 1.1.1", :"shared assertion 1.1.2", 
                :"shared assertion 2", :"assertion 2.3", 
                :"shared assertion 4.1", :"assertion 2.2"]
    assert_equal expected, root.children[0].children[0].children[2].collect_assertions.map {|a| a.name }

    expected = [:"shared assertion 1.2", :"shared assertion 2", 
                :"assertion 2.3", :"shared assertion 4.1", 
                :"assertion 2.2"]
    assert_equal expected, root.children[1].children[0].children[2].collect_assertions.map {|a| a.name }

    expected = [:"shared assertion 1.2", :"shared assertion 2", 
                :"assertion 2.3", :"shared assertion 4.2", 
                :"assertion 2.2"]
    assert_equal expected, root.children[1].children[0].children[3].collect_assertions.map {|a| a.name }
  end
  
  def test_leafs
    root = @group.expand.first
    expected = [ :"context 3.1", :"context 3.2", :"context 4", :"context 4", 
                 :"context 3.1", :"context 3.2", :"context 4", :"context 4"]
    assert_equal expected, root.leafs.map {|c| c.name }
  end
  
  def test_compile
    root = @group.expand.first
    method = root.leafs.first.compile
    expected = [ "precondition 1.1",
                 "precondition 2",
                 "precondition 3.1",
                 "action",
                 "shared assertion 1.1.1",
                 "shared assertion 1.1.2",
                 "shared assertion 2",
                 "assertion 2.3",
                 "shared assertion 3.1",
                 "assertion 2.1" ]
    assert_equal expected, method.call.map {|result| result.to_s.gsub(/ #<.*>/, '') }

    method = root.leafs.last.compile
    expected = [ "precondition 1.2",
                 "precondition 2",
                 "precondition 4.2",
                 "action",
                 "shared assertion 1.2",
                 "shared assertion 2",
                 "assertion 2.3",
                 "shared assertion 4.2",
                 "assertion 2.2" ]
    assert_equal expected, method.call.map {|result| result.to_s.gsub(/ #<.*>/, '') }
  end
end