require 'spec_helper'

module Missingly
  describe Matchers do
    let(:our_class) do
      Class.new do
        include Missingly::Matchers

        handle_missingly /find_by_*/ do
        end
      end
    end

    let(:instance) do
      our_class.new
    end

    context "respond_to?" do
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
  end
end
