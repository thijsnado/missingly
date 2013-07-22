module Missingly
  class RegexBlockMatcher < BlockMatcher
    attr_reader :regex, :method_block, :options

    def initialize(regex, options, method_block)
      @regex, @options, @method_block = regex, options, method_block
    end

    def should_respond_to?(instance, name)
      regex.match(name)
    end

    def setup_method_name_args(method_name)
      regex.match method_name
    end

    def matchable; regex; end
  end
end
