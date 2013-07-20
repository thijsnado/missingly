module Missingly
  class RegexMatcher
    attr_reader :regex, :options, :method_block

    def initialize(regex, options, method_block)
      @regex, @options, @method_block = regex, options, method_block
    end

    def matchable
      regex
    end

    def should_respond_to?(name)
      regex.match(name)
    end

    def handle(instance, method_name, *args, &block)
      if method_block
        matches = regex.match method_name

        sub_name = "#{method_name}_with_matches"
        instance.class._define_method method_name do |*the_args, &the_block|
          public_send(sub_name, matches, *the_args, &the_block)
        end
        instance.class._define_method(sub_name, &method_block)

        instance.public_send(method_name, *args, &block)
      elsif options[:to]
        instance.class.class_eval <<-CODE
          def #{method_name}(*args, &block)
            #{options[:to]}.#{method_name}(*args, &block)
          end
        CODE

        instance.public_send(method_name, *args, &block)
      else
        raise ArgumentError, "either block, or to option should be passed"
      end
    end
  end
end
