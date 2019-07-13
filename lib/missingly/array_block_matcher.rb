# frozen_string_literal: true

module Missingly
  class ArrayBlockMatcher < BlockMatcher
    attr_reader :array, :method_block, :options

    def initialize(array, options, method_block)
      @array, @method_block, @options = array, method_block, options
    end

    def should_respond_to?(instance, name)
      array.include?(name)
    end

    def setup_method_name_args(method_name)
      method_name
    end

    def matchable; array; end
  end
end
