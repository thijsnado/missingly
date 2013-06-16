module Missingly
  module Matchers
    module ClassMethods
      def handle_missingly(regular_expression)
        define_method "respond_to_missing?" do |method_name, include_all|
          regular_expression.match method_name
        end
      end
    end

    def self.included(klass)
      klass.extend ClassMethods
    end
  end
end
