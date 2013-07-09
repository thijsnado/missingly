require 'spec_helper'

class AttrTest
  include Missingly::Matchers
  
  missingly_reader [:foo], @hash
  missingly_writer [:bar], @hash
  missingly_accessor [:widget], @hash
  
  def initialize
    @hash = {foo: "rspec", bar: "rspec2", widget: "rspec3"}
  end
end

describe "attr_matchers" do
  it "should define a reader" do
    a = AttrTest.new
    a.foo.should eq "rspec"
  end
  
  it "should define a writer" do
    a = AttrTest.new
    a.bar = "foo"
  end
  
  it "should define an accessor" do
    a = AttrTest.new
    a.widget.should eq "rspec3"
    a.widget = "foo"
    a.widget.should eq "foo"
  end
end