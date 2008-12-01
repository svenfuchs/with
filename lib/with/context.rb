require 'with/dsl'

module With
  class Context
    include Dsl

    attr_reader :name

    def initialize(name, action, preconditions, assertions, &block)
      @name, @action, @preconditions, @assertions = name, action, [], []
      @children = []

      instance_eval &block if block

      @preconditions += preconditions
      @assertions += assertions
    end

    def leafs
      return self if children.empty?
      children.map { |child| child.leafs }.flatten
    end

    def calls
      [find_action, collect_preconditions, collect_assertions]
    end

    def add_children(*children)
      children.each do |child|
        child.parent = self
        @children << child
      end
    end

    def self_and_parents
      (parent ? parent.self_and_parents : []) + [self]
    end

    protected

      def find_action
        @action || parent && parent.find_action || raise("could not find action")
      end

      def collect_preconditions
        (parent ? parent.collect_preconditions : []) + preconditions
      end

      def collect_assertions
        (parent ? parent.collect_assertions : []) + assertions
      end
  end
end