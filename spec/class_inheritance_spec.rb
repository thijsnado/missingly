require 'spec_helper'

describe Missingly::Matchers do
  let(:super_class) do
    Class.new do
      include Missingly::Matchers

      handle_missingly [:foo] do |method|
        return method
      end
    end
  end

  let(:subclass) do
    Class.new(super_class) do
    end
  end

  it "should work with an inherited class" do
    b = subclass.new
    b.foo.should eq :foo
  end

  it "should allow override of parent class" do
    subclass.module_eval do
      handle_missingly [:foo] do |method|
        :super_duper
      end
    end

    subclass.new.foo.should eq :super_duper
  end
end
