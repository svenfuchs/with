module With
  module Sharing
    def share(name, *shareds, &block)
      shareds << block if block
      shareds.each do |shared| 
        group = shared.is_a?(Group) ? shared : Group.new(name, &shared)
        
        self.shared[name] ||= []
        self.shared[name] << group
      end
    end

    def shared
      @shared ||= {}
    end
  end
end