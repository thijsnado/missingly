# frozen_string_literal: true

module Missingly
  class ArrayBlockMatcher < BlockMatcher
    attr_reader :array, :method_block, :options

    def initialize(array, options, method_block)
      @array = array
      @method_block = method_block
      @options = options
    end

    def should_respond_to?(_instance, name)
      array.include?(name)
    end

    def setup_method_name_args(method_name)
      method_name
    end

    def matchable
      array
    end
  end
end
