module Missingly
  module Matchers
    module ClassMethods
      def handle_missingly(regular_expression_or_array, &block)
        match_method_pairs << [regular_expression_or_array, block]
      end

      def match_method_pairs
        @match_method_pairs ||= []
      end

      def _define_method(*args, &block)
        define_method(*args, &block)
      end
    end

    def respond_to_missing?(method_name, include_all)
      matchers = self.class.match_method_pairs.map{ |m| m.first }
      matchers.each do |matchable|
        should_respond_to = respond_to_missingly?(matchable, method_name)
        return true if should_respond_to
      end
      super
    end

    def method_missing(method_name, *args, &block)
      self.class.match_method_pairs.each_with_index do |pair|
        matchable = pair[0]
        method_block = pair[1]

        next unless respond_to_missingly?(matchable, method_name)

        return case matchable
               when Regexp then handle_regex(matchable, method_block, method_name, *args, &block)
               when Array then handle_array(method_block, method_name, *args, &block)
               end
      end
      super
    end

    private

    def respond_to_missingly?(matchable, method_name)
      case matchable
      when Regexp then matchable.match(method_name)
      when Array  then matchable.include?(method_name.to_sym)
      end
    end

    def handle_regex(matchable, method_block, method_name, *args, &block)
      matches = matchable.match method_name

      sub_name = "#{method_name}_with_matches"
      self.class._define_method method_name do |*the_args, &the_block|
        public_send(sub_name, matches, *the_args, &the_block)
      end
      self.class._define_method(sub_name, &method_block)

      public_send(method_name, *args, &block)
    end

    def handle_array(method_block, method_name, *args, &block)
      sub_name = "#{method_name}_with_method_name"

      self.class._define_method method_name do |*the_args, &the_block|
        public_send(sub_name, method_name, *the_args, &the_block)
      end
      self.class._define_method(sub_name, &method_block)

      public_send(method_name, *args, &block)
    end

    def self.included(klass)
      klass.extend ClassMethods
    end
  end
end
