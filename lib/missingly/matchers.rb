module Missingly
  module Matchers
    module ClassMethods
      def handle_missingly(matcher, options={}, &block)
        if options[:with]
          setup_custom_handler(matcher, options, &block)
        elsif block_given?
          setup_block_handlers(matcher, &block)
        elsif options[:to]
          setup_delegation_handlers(matcher, options[:to])
        end
      end

      def setup_custom_handler(matcher, options={}, &block)
        missingly_matchers[matcher] = options[:with].new(matcher, options, block)
      end

      def setup_block_handlers(matcher, &block)
        case matcher
        when Array then missingly_matchers[matcher] = ArrayBlockMatcher.new(matcher, block)
        when Regexp then missingly_matchers[matcher] = RegexBlockMatcher.new(matcher, block)
        end
      end

      def setup_delegation_handlers(matcher, to)
        case matcher
        when Array then missingly_matchers[matcher] = ArrayDelegateMatcher.new(matcher, to)
        when Regexp then missingly_matchers[matcher] = RegexDelegateMatcher.new(matcher, to)
        end
      end

      def missingly_matchers
        @missingly_matchers ||= {}
      end

      def _define_method(*args, &block)
        define_method(*args, &block)
      end

      def inherited(subclass)
        matchers = self.missingly_matchers
        subclass.module_eval do
          @missingly_matchers =  matchers.clone
        end
      end
    end

    def respond_to_missing?(method_name, include_all)
      self.class.missingly_matchers.values.each do |matcher|
        return true if matcher.should_respond_to?(self, method_name.to_sym)
      end
      super
    end
    private :respond_to_missing?

    def method_missing(method_name, *args, &block)
      self.class.missingly_matchers.values.each do |matcher|
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
