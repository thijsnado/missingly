# frozen_string_literal: true

require 'spec_helper'

module Missingly
  describe Matchers do
    context 'respond_to?' do
      let(:our_class) do
        Class.new do
          include Missingly::Matchers

          handle_missingly [:derp, :herp] do
          end
        end
      end

      let(:instance) do
        our_class.new
      end

      it 'should respond to methods that are included in array' do
        expect(instance.respond_to?(:derp)).to eq(true)
        expect(instance.respond_to?(:herp)).to eq(true)
        expect(instance.respond_to?('herp')).to eq(true)
        expect(instance.respond_to?('fluffy_buffy_bunnies')).to eq(false)
      end
    end

    context 'method_missing' do
      let(:our_class) do
        Class.new do
          include Missingly::Matchers

          attr_accessor :method_name, :args, :block, :expected_self

          handle_missingly [:derp] do |method_name, *args, &block|
            @expected_self = self
            @method_name = method_name
            @args = args
            @block = block
          end
        end
      end

      let(:instance) do
        our_class.new
      end

      it 'should also work with arrays, but just passes method name instead of match object' do
        args = [1, 2, 3]
        prock = proc { puts 'foo' }
        instance.derp(*args, &prock)

        expect(instance.expected_self).to eq(instance)
        expect(instance.method_name).to eq(:derp)
        expect(instance.args).to eq(args)
        expect(instance.block).to eq(prock)
      end

      it 'should work with subsequent calls' do
        args = [1, 2, 3]
        prock = proc { puts 'foo' }
        instance.derp(*args, &prock)
        instance.derp(*args, &prock)

        expect(instance.expected_self).to eq(instance)
        expect(instance.method_name).to eq(:derp)
        expect(instance.args).to eq(args)
        expect(instance.block).to eq(prock)
      end
    end
  end
end
