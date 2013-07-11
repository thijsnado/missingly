module Missingly
  class DelegateMatcher
    def handle(instance, name, *args, &block)
      if should_respond_to?(instance, name)
        instance.class.class_eval <<-RUBY, __FILE__, __LINE__
          def #{name}(*args, &block)
            #{delegate_name}.#{name}(*args, &block)
          end
        RUBY
        instance.public_send(name, *args, &block)
      else
        super
      end
    end
  end
end
