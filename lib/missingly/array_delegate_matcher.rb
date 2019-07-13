# frozen_string_literal: true

module Missingly
  class ArrayDelegateMatcher < DelegateMatcher
    attr_reader :array, :options, :delegate_name

    def initialize(array, options, delegate_name)
      @array, @options, @delegate_name = array, options, delegate_name
    end

    def should_respond_to?(instance, name)
      included_in_array = array.include?(name)
      delegate_responds_to = instance.send(delegate_name).respond_to?(name)
      included_in_array && delegate_responds_to
    end

    def matchable; array; end
  end
end
