module Missingly
  class ArrayBlockMatcher
    attr_reader :array, :method_block

    def initialize(array, method_block)
      @array, @method_block = array, method_block
    end

    def should_respond_to?(instance, name)
      array.include?(name)
    end

    def handle(instance, method_name, *args, &block)
      sub_name = "#{method_name}_with_method_name"

      instance.class._define_method method_name do |*the_args, &the_block|
        public_send(sub_name, method_name, *the_args, &the_block)
      end
      instance.class._define_method(sub_name, &method_block)

      instance.public_send(method_name, *args, &block)
    end
  end
end
