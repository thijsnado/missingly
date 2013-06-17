module Missingly
  module Matchers
    module ClassMethods
      def handle_missingly(regular_expression, &block)
        match_method_pairs << [regular_expression, block]
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
        return true if matchable.match(method_name)
      end
      super
    end

    def method_missing(name, *args, &block)
      self.class.match_method_pairs.each_with_index do |pair|
        matcher = pair[0]
        method_block = pair[1]
        matches = matcher.match name

        next unless matches

        sub_name = name.to_s + '_with_matches'
        self.class._define_method name do |*the_args, &the_block|
          public_send(sub_name, matches, *the_args, &the_block)
        end
        self.class._define_method(sub_name, &method_block)

        return public_send(name, *args, &block)
      end
      super
    end

    def self.included(klass)
      klass.extend ClassMethods
    end
  end
end
