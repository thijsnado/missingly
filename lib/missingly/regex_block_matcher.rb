module Missingly
  class RegexBlockMatcher
    attr_reader :regex, :method_block

    def initialize(regex, method_block)
      @regex, @method_block = regex, method_block
    end

    def should_respond_to?(name)
      regex.match(name)
    end

    def handle(instance, method_name, *args, &block)
      matches = regex.match method_name

      sub_name = "#{method_name}_with_matches"
      instance.class._define_method method_name do |*the_args, &the_block|
        public_send(sub_name, matches, *the_args, &the_block)
      end
      instance.class._define_method(sub_name, &method_block)

      instance.public_send(method_name, *args, &block)
    end
  end
end
