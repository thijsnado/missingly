require 'spec_helper'

module Missingly
  describe Matchers do
    context "respond_to?" do
      let(:our_class) do
        Class.new do
          include Missingly::Matchers

          handle_missingly /^find_by_(\w+)$/ do
          end
        end
      end

      let(:instance) do
        our_class.new
      end
      it "should only respond to methods that match regular expression passed to missingly" do
        instance.respond_to?("find_by_id").should == true
        instance.respond_to?("fluffy_buffy_bunnies").should == false
      end

      it "should not make respond_to_missing? public" do
        instance.respond_to?("respond_to_missing?").should == false
      end

      it "should also work with inheritance" do
        foo = Class.new do
          def respond_to_missing?(name, include_all)
            name.to_s == 'this_should_work'
          end
        end

        bar = Class.new(foo) do
          include Missingly::Matchers

          handle_missingly /foo/ do
          end
        end

        bar.new.respond_to?('this_should_work').should == true
      end

      it "should work with multiple definitions" do
        our_class.module_eval do

          handle_missingly /foo/ do
          end
        end
        instance.respond_to?('foo').should == true
        instance.respond_to?('find_by_id').should == true
      end
    end

    context "method_missing" do
      let(:our_class) do
        class Foo
          include Missingly::Matchers

          attr_accessor :matched_text, :args, :block, :expected_self

          handle_missingly /^find_by_(\w+)$/ do |matches, *args, &block|
            @expected_self = self
            @matched_text = matches[1]
            @args = args
            @block = block
          end
        end
      end

      let(:instance) do
        our_class
        Foo.new
      end

      it "should call method that matches regular expression on instances passing matches and args and block" do
        args = [1, 2, 3]
        prock = Proc.new { puts 'foo' }
        instance.find_by_id_and_first_name(*args, &prock)

        instance.expected_self.should == instance
        instance.matched_text.should == 'id_and_first_name'
        instance.args.should == args
        instance.block.should == prock
      end

      it "should define the method on call preventing further method missing calls on same class" do
        args = [1, 2, 3]
        prock = Proc.new { puts 'foo' }
        instance.find_by_id_and_first_name(*args, &prock)
        Method.should === instance.method(:find_by_id_and_first_name)
      end
    end
  end
end
