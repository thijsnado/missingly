require 'spec_helper'

class Foo
  include Missingly::Matchers
  
  handle_missingly [:foo] do |method|
    return method
  end
end

class Bar < Foo
end

describe Missingly::Matchers do
  it "should work with an inherited class" do
    f = Foo.new
    b = Bar.new
    b.foo.should eq :foo
  end
end