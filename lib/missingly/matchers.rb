module Missingly
  module Matchers
    module ClassMethods
      def handle_missingly(regular_expression)
        missingly_matchers << regular_expression
      end

      def missingly_matchers
        @missingly_matchers ||= []
      end
    end

    def respond_to_missing?(method_name, include_all)
      self.class.missingly_matchers.each do |matchable|
        return true if !!matchable.match(method_name)
      end
      super
    end

    def self.included(klass)
      klass.extend ClassMethods
    end
  end
end
