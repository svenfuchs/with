$:.unshift File.dirname(__FILE__) + '/../lib/'
require 'with'

class Target
  include With
  
  class << self
    def reset
      With.shared.clear
      with_common.clear
      instance_methods.select{|m| m =~ /^test_/ }.each {|m| Target.send(:remove_method, m) }
    end
  end
  
  def called
    @called ||= []
  end
  
  def with?(name)
    @_with_contexts.include?(name)
  end
end

class Symbol
  def to_proc
    Proc.new { |*args| args.shift.__send__(self, *args) }
  end
end

class Test::Unit::TestCase
  def context_names(contexts)
    contexts.map do |context| 
      context.leafs.map { |leaf| (leaf.parents << leaf).map(&:name) }
    end
  end
end

class With
  class Node
    def inspect
      $_INDENT ||= 0
      $_INDENT += 1
      s = "\n#<Context:#{self.object_id} @name=#{name.inspect}\n"
      s << "  @parent(#{parent.object_id})=#{parent.name.inspect}\n" unless parent.nil?
      s << "  @calls(#{@calls.object_id})=#{@calls.inspect}\n" unless @calls.empty?
      s << "  @children(#{@children.object_id})=#{children.inspect}" unless children.empty?
      s << ">"
      s = s.split(/\n/).map{|s| ' ' * $_INDENT + s }.join("\n")
      $_INDENT -= 1
      s
    end
  end

  class Call
    def inspect
      s = "#<Call:#{self.object_id} @name=#{name.inspect}"
      s << " @conditions=#{@conditions.inspect}" unless @conditions.empty?
      s + '>'
    end
  end
end