module Missingly
  class RegexDelegateMatcher < DelegateMatcher
    attr_reader :regex, :delegate_name

    def initialize(regex, delegate_name)
      @regex, @delegate_name = regex, delegate_name
    end

    def should_respond_to?(instance, name)
      matches = regex.match name
      delegate_responds_to = instance.send(delegate_name).respond_to?(name)
      matches && delegate_responds_to
    end
  end
end
