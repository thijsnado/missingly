module Missingly
  class ArrayBlockMatcher < BlockMatcher
    attr_reader :array, :method_block

    def initialize(array, method_block)
      @array, @method_block = array, method_block
    end

    def should_respond_to?(instance, name)
      array.include?(name)
    end

    def setup_method_name_args(method_name)
      method_name
    end
  end
end
