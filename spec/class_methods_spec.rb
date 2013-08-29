require 'spec_helper'

describe Missingly::Matchers do
  let(:search_class) do
    Class.new do
      include Missingly::Matchers

      handle_missingly [:find_by_name], class_method: true do |method_name, *args|
        return {foo: args.first || 'bar'}
      end

      handle_missingly /^find_all_by_(\w+)$/, class_method: true do |matches, *args, &block|
        return matches
      end
    end
  end

  let(:delegation_test) do
    Class.new(search_class) do
      handle_missingly [:find_by_foo], to: :proxy, class_method: true

      def self.proxy
        OpenStruct.new({find_by_foo: "foo"})
      end
    end
  end


  it "should not break normal method_missing" do
    search_class.new.respond_to?("foo_bar_widget").should be_false
  end

  it "should allow you to define class methods" do
    search_class.respond_to?("find_by_name").should be_true
    search_class.respond_to?("find_all_by_name").should be_true
    search_class.find_all_by_name.should be_a MatchData
    search_class.find_by_name.should be_a Hash
  end

  it "should support delegation matchers" do
    delegation_test.respond_to?("find_by_foo").should be_true
    delegation_test.find_by_foo.should be_true
  end

  it "should not make class methods available to instances" do
    search_class.new.respond_to?("find_by_name").should be_false
    lambda { search_class.new.find_by_name("foo") }.should raise_exception
  end

  it "should work through inheritence" do
    delegation_test.respond_to?("find_all_by_name").should be_true
    delegation_test.find_all_by_name.should be_a MatchData
  end

  it "should accept method arguments" do
    search_class.find_by_name("arg_test").should == {foo: "arg_test"}
  end
end
