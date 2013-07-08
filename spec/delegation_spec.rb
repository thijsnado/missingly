require 'spec_helper'

module Missingly
  describe Matchers do
    let(:our_class) do
      Class.new do
        include Missingly::Matchers

        handle_missingly [:derp], to: :proxy
        handle_missingly /^find_by_(\w+)$/, to: :proxy
      end
    end

    let(:proxy){ stub }

    let(:instance) do
      i = our_class.new
      i.stub(:proxy).and_return(proxy)
      i
    end

    it "should delegate method to attribute passed to to option for arrays" do
      args = [1, 2]
      prock = Proc.new{ puts "Don't call" }

      args_passed = nil
      block_passed = nil
      proxy.should_receive(:derp) do |*_args|
        args_passed = _args.first(2)
        block_passed = _args.last
      end

      instance.derp(*args, *prock)

      args_passed.should == args
      block_passed.should == prock
    end

    it "should delegate method to attribute passed to to option for regexes" do
      args = [1, 2]
      prock = Proc.new{ puts "Don't call" }

      args_passed = nil
      block_passed = nil
      proxy.should_receive(:find_by_id) do |*_args|
        args_passed = _args.first(2)
        block_passed = _args.last
      end

      instance.find_by_id(*args, *prock)

      args_passed.should == args
      block_passed.should == prock
    end
  end
end
