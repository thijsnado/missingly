module Missingly
  class ArrayMatcher
    attr_reader :array, :options, :method_block

    def initialize(array, options, method_block)
      @array, @options, @method_block = array, options, method_block
    end

    def should_respond_to?(name)
      array.include?(name)
    end

    def handle(instance, method_name, *args, &block)
      if method_block
        sub_name = "#{method_name}_with_method_name"

        instance.class._define_method method_name do |*the_args, &the_block|
          public_send(sub_name, method_name, *the_args, &the_block)
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
