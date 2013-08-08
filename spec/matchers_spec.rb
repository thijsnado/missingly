module Missingly
  describe Matchers do
    describe "#handle_missingly" do
      it "can be used to override previous missingly with same matcher" do
        klass = Class.new do
          include Missingly::Matchers

          handle_missingly /foo/ do |*args|
            'foo'
          end

          handle_missingly /foo/ do |*args|
            'bar'
          end
        end

        klass.new.foo.should eq('bar')

        another_klass = Class.new do
          include Missingly::Matchers

          handle_missingly /foo/ do |*args|
            'foo'
          end
        end

        another_klass.new.foo

        another_klass.module_eval do
          handle_missingly /foo/ do |*args|
            'bar'
          end
        end

        another_klass.new.foo.should eq('bar')
      end
    end
  end
end
