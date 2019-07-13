# frozen_string_literal: true

module Missingly
  class DelegateMatcher
    def define(instance, name)
      instance.class.class_eval <<-RUBY, __FILE__, __LINE__
        def #{name}(*args, &block)
          #{delegate_name}.#{name}(*args, &block)
        end
      RUBY
    end
  end
end
