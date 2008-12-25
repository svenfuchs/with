module With
  module Sharing
    def share(group, name = nil, &block)
      self.shared[group] ||= []
      self.shared[group] << Context.new(name || group, &block)
    end

    def shared(name = nil)
      @@shared ||= {}
      name.nil? ? @@shared : begin
        raise "could not find shared context #{name.inspect}" unless @@shared.has_key?(name)
        @@shared[name].map {|context| context.clone }
      end
    end
  end
end