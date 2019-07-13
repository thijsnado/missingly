# frozen_string_literal: true

module Missingly
  module Mutex
    @mutex = ::Mutex.new

    def self.synchronize(&block)
      @mutex.synchronize(&block)
    end
  end

  module Matchers
    module ClassMethods
      def handle_missingly(matcher, options = {}, &block)
        undef_parent_missingly_methods matcher
        undef_normal_missingly_methods matcher

        if options[:with]
          setup_custom_handler(matcher, options, &block)
        elsif block_given?
          setup_block_handlers(matcher, options, &block)
        elsif options[:to]
          setup_delegation_handlers(matcher, options, options[:to])
        end
      end

      def setup_custom_handler(matcher, options, &block)
        missingly_matchers[matcher] = options[:with].new(matcher, options, block)
      end

      def setup_block_handlers(matcher, options, &block)
        case matcher
        when Array then missingly_matchers[matcher] = ArrayBlockMatcher.new(matcher, options, block)
        when Regexp then missingly_matchers[matcher] = RegexBlockMatcher.new(matcher, options, block)
        end
      end

      def setup_delegation_handlers(matcher, options, to)
        case matcher
        when Array then missingly_matchers[matcher] = ArrayDelegateMatcher.new(matcher, options, to)
        when Regexp then missingly_matchers[matcher] = RegexDelegateMatcher.new(matcher, options, to)
        end
      end

      def undef_parent_missingly_methods(matcher)
        superclass = self.superclass
        matchers = []

        while superclass.respond_to?(:missingly_methods_for_matcher)
          matchers.concat superclass.missingly_methods_for_matcher(matcher)
          superclass = superclass.superclass
        end

        undef_missingly_methods(matchers)
      end

      def undef_normal_missingly_methods(matcher)
        undef_missingly_methods(missingly_methods_for_matcher(matcher))
      end

      def undef_missingly_methods(methods)
        methods.each do |method|
          begin
            undef_method method
          rescue NameError
            (class << self; self; end).undef_method method
          end
        end
      end

      def missingly_subclasses
        @missingly_subclasses ||= []
      end

      def missingly_matchers
        @missingly_matchers ||= {}
      end

      def missingly_methods
        @missingly_methods ||= {}
      end

      def missingly_methods_for_matcher(matcher)
        missingly_methods[matcher] ||= []
      end

      def _define_method(*args, &block)
        define_method(*args, &block)
      end

      def inherited(subclass)
        matchers = missingly_matchers
        subclass.class_eval do
          @missingly_matchers = matchers.clone
        end
        missingly_subclasses << subclass
      end

      def method_missing(method_name, *args, &block)
        missingly_matchers.values.each do |matcher|
          next unless matcher.should_respond_to?(self, method_name)
          next unless matcher.options[:class_method]

          Missingly::Mutex.synchronize do
            missingly_methods_for_matcher(matcher.matchable) << method_name

            matcher.define(self, method_name)

            missingly_subclasses.each do |subclass|
              subclass.undef_parent_missingly_methods matcher.matchable
            end

            return public_send(method_name, *args, &block)
          end
        end
        super
      end

      def respond_to_missing?(method_name, include_all)
        missingly_matchers.values.each do |matcher|
          return true if matcher.should_respond_to?(self, method_name.to_sym) && matcher.options[:class_method]
        end
        super
      end
    end

    def respond_to_missing?(method_name, include_all)
      self.class.missingly_matchers.values.each do |matcher|
        return true if matcher.should_respond_to?(self, method_name.to_sym) && !matcher.options[:class_method]
      end
      super
    end

    def method_missing(method_name, *args, &block)
      self.class.missingly_matchers.values.each do |matcher|
        next unless matcher.should_respond_to?(self, method_name)
        next if matcher.options[:class_method]

        Missingly::Mutex.synchronize do
          self.class.missingly_methods_for_matcher(matcher.matchable) << method_name

          matcher.define(self, method_name)

          self.class.missingly_subclasses.each do |subclass|
            subclass.undef_parent_missingly_methods matcher.matchable
          end

          return public_send(method_name, *args, &block)
        end
      end
      super
    end

    def self.included(klass)
      klass.extend ClassMethods
    end
  end
end
