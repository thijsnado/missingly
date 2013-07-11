module Missingly
  module Matchers
    module ClassMethods
      def handle_missingly(regular_expression_or_array, options={}, &block)
        if block_given?
          setup_block_handlers(regular_expression_or_array, &block)
        elsif options[:to]
          setup_delegation_handlers(regular_expression_or_array, options[:to])
        end
      end

      def setup_block_handlers(regular_expression_or_array, &block)
        case regular_expression_or_array
        when Array then missingly_matchers << ArrayBlockMatcher.new(regular_expression_or_array, block)
        when Regexp then missingly_matchers << RegexBlockMatcher.new(regular_expression_or_array, block)
        end
      end

      def setup_delegation_handlers(regular_expression_or_array, to)
        case regular_expression_or_array
        when Array then missingly_matchers << ArrayDelegateMatcher.new(regular_expression_or_array, to)
        when Regexp then missingly_matchers << RegexDelegateMatcher.new(regular_expression_or_array, to)
        end
      end

      def missingly_matchers
        @missingly_matchers ||= []
      end

      def _define_method(*args, &block)
        define_method(*args, &block)
      end
    end

    def respond_to_missing?(method_name, include_all)
      self.class.missingly_matchers.each do |matcher|
        return true if matcher.should_respond_to?(self, method_name.to_sym)
      end
      super
    end
    private :respond_to_missing?

    def method_missing(method_name, *args, &block)
      self.class.missingly_matchers.each do |matcher|
        next unless matcher.should_respond_to?(self, method_name)

        return matcher.handle(self, method_name, *args, &block)
      end
      super
    end

    private

    def self.included(klass)
      klass.extend ClassMethods
    end
  end
end
