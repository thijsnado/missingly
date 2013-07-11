module Missingly
  class ArrayDelegateMatcher < DelegateMatcher
    attr_reader :array, :delegate_name

    def initialize(array, delegate_name)
      @array, @delegate_name = array, delegate_name
    end

    def should_respond_to?(instance, name)
      included_in_array = array.include?(name)
      delegate_responds_to = instance.send(delegate_name).respond_to?(name)
      included_in_array && delegate_responds_to
    end
  end
end
