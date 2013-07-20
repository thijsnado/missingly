require 'thread'

module Missingly
  module Mutex
    @mutex = ::Mutex.new

    def self.synchronize(&block)
      @mutex.synchronize(&block)
    end
  end

  module Matchers
    module ClassMethods
      def handle_missingly(regular_expression_or_array, options={}, &block)
        undef_parent_missingly_methods regular_expression_or_array

        case regular_expression_or_array
        when Array then missingly_matchers[regular_expression_or_array] = ArrayMatcher.new(regular_expression_or_array, options, block)
        when Regexp then missingly_matchers[regular_expression_or_array] = RegexMatcher.new(regular_expression_or_array, options, block)
        end
      end

      def undef_parent_missingly_methods(matcher)
        return unless superclass.respond_to?(:missingly_methods_for_matcher)

        superclass.missingly_methods_for_matcher(matcher).each do |method|
          undef_method method
        end
      end

      def missingly_subclasses
        @missingly_subclasses ||= []
      end

      def missingly_matchers
        @missingly_matchers ||= {}
      end

      def missingly_methods
        @missingly_methods ||= Hash.new()
      end

      def missingly_methods_for_matcher(matcher)
        missingly_methods[matcher] ||= []
      end

      def _define_method(*args, &block)
        define_method(*args, &block)
      end

      def inherited(subclass)
        matchers = self.missingly_matchers
        subclass.class_eval do
          @missingly_matchers =  matchers.clone
        end
        missingly_subclasses << subclass
      end
    end

    def respond_to_missing?(method_name, include_all)
      self.class.missingly_matchers.values.each do |matcher|
        return true if matcher.should_respond_to?(method_name.to_sym)
      end
      super
    end
    private :respond_to_missing?

    def method_missing(method_name, *args, &block)
      self.class.missingly_matchers.values.each do |matcher|
        next unless matcher.should_respond_to?(method_name)

        Missingly::Mutex.synchronize do
          self.class.missingly_methods_for_matcher(matcher.matchable) << method_name

          returned_value = matcher.handle(self, method_name, *args, &block)

          self.class.missingly_subclasses.each do |subclass|
            subclass.undef_parent_missingly_methods matcher.matchable
          end

          return returned_value
        end
      end
      super
    end

    private

    def self.included(klass)
      klass.extend ClassMethods
    end
  end
end
