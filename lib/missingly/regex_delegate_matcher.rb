module Missingly
  class RegexDelegateMatcher < DelegateMatcher
    attr_reader :regex, :options, :delegate_name

    def initialize(regex, options, delegate_name)
      @regex, @options, @delegate_name = regex, options, delegate_name
    end

    def should_respond_to?(instance, name)
      matches = regex.match name
      delegate_responds_to = instance.send(delegate_name).respond_to?(name)
      matches && delegate_responds_to
    end

    def matchable; regex; end
  end
end
