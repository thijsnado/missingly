module Missingly
  module Matchers
    module ClassMethods
      def handle_missingly(matcher, options={}, &block)
        if matcher.is_a? Class
          setup_custom_handler(matcher, options, &block)
        elsif block_given?
          setup_block_handlers(matcher, &block)
        elsif options[:to]
          setup_delegation_handlers(matcher, options[:to])
        end
      end

      def setup_custom_handler(matcher, options={}, &block)
        missingly_matchers << matcher.new(options, block)
      end

      def setup_block_handlers(matcher, &block)
        case matcher
        when Array then missingly_matchers << ArrayBlockMatcher.new(matcher, block)
        when Regexp then missingly_matchers << RegexBlockMatcher.new(matcher, block)
        end
      end

      def setup_delegation_handlers(matcher, to)
        case matcher
        when Array then missingly_matchers << ArrayDelegateMatcher.new(matcher, to)
        when Regexp then missingly_matchers << RegexDelegateMatcher.new(matcher, to)
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
