module Missingly
  class BlockMatcher
    def handle(instance, method_name, *args, &block)
      sub_name = "_#{method_name}_submethod"

      method_name_args = setup_method_name_args(method_name)

      instance.class._define_method method_name do |*the_args, &the_block|
        public_send(sub_name, method_name_args, *the_args, &the_block)
      end
      instance.class._define_method(sub_name, &method_block)

      instance.public_send(method_name, *args, &block)
    end
  end
end
