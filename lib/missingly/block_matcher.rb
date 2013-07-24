module Missingly
  class BlockMatcher
    def handle(instance, method_name, *args, &block)
            
      klass = instance.class == Class ? instance : instance.class

      if instance.class == Class
        define_class_method(klass, method_name)
      else
        define_instance_method(klass, method_name)
      end
      
      instance.public_send(method_name, *args, &block)
    end
    
    def define_class_method(klass, method_name)
      sub_name = "_#{method_name}_submethod"
      method_name_args = setup_method_name_args(method_name)
      
      klass.define_singleton_method method_name do |*the_args, &the_block|
        public_send(sub_name, method_name_args, *the_args, &the_block)
      end
      klass.define_singleton_method(sub_name, &method_block)
    end
    
    def define_instance_method(klass, method_name)
      sub_name = "_#{method_name}_submethod"
      method_name_args = setup_method_name_args(method_name)
      
      klass._define_method method_name do |*the_args, &the_block|
        public_send(sub_name, method_name_args, *the_args, &the_block)
      end
      klass._define_method(sub_name, &method_block)
    end
  end
end
