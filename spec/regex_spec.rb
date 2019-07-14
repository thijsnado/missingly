# frozen_string_literal: true

require 'spec_helper'

module Missingly
  describe Matchers do
    context 'respond_to?' do
      let(:our_class) do
        Class.new do
          include Missingly::Matchers

          handle_missingly(/^find_by_(\w+)$/) do
          end
        end
      end

      let(:instance) do
        our_class.new
      end

      it 'should only respond to methods that match regular expression passed to missingly' do
        expect(instance.respond_to?('find_by_id')).to eq(true)
        expect(instance.respond_to?('fluffy_buffy_bunnies')).to eq(false)
      end

      it 'should not make respond_to_missing? public' do
        expect(instance.respond_to?('respond_to_missing?')).to eq(false)
      end

      it 'should also work with inheritance' do
        foo = Class.new do
          def respond_to_missing?(name, _include_all)
            name.to_s == 'this_should_work'
          end
        end

        bar = Class.new(foo) do
          include Missingly::Matchers

          handle_missingly(/foo/) do
          end
        end

        expect(bar.new.respond_to?('this_should_work')).to eq(true)
      end

      it 'should work with multiple definitions' do
        our_class.module_eval do
          handle_missingly(/foo/) do
          end
        end
        expect(instance.respond_to?('foo')).to eq(true)
        expect(instance.respond_to?('find_by_id')).to eq(true)
      end
    end

    context 'method_missing' do
      let(:our_class) do
        Class.new do
          include Missingly::Matchers

          attr_accessor :matched_text, :args, :block, :expected_self

          handle_missingly(/^find_by_(\w+)$/) do |matches, *args, &block|
            @expected_self = self
            @matched_text = matches[1]
            @args = args
            @block = block
          end
        end
      end

      let(:instance) do
        our_class.new
      end

      it 'should call method that matches regular expression on instances passing matches and args and block' do
        args = [1, 2, 3]
        prock = proc { puts 'foo' }
        instance.find_by_id_and_first_name(*args, &prock)

        expect(instance.expected_self).to eq(instance)
        expect(instance.matched_text).to eq('id_and_first_name')
        expect(instance.args).to eq(args)
        expect(instance.block).to eq(prock)
      end

      it 'should work with subsequent calls' do
        args = [1, 2, 3]
        prock = proc { puts 'foo' }
        instance.find_by_id_and_first_name(*args, &prock)
        instance.find_by_id_and_first_name(*args, &prock)

        expect(instance.expected_self).to eq(instance)
        expect(instance.matched_text).to eq('id_and_first_name')
        expect(instance.args).to eq(args)
        expect(instance.block).to eq(prock)
      end

      it 'should also work with arrays, but just passes method name instead of match object' do
        our_class.module_eval do
          attr_reader :method_name
          handle_missingly [:derp] do |method_name, *args, &block|
            @expected_self = self
            @method_name = method_name
            @args = args
            @block = block
          end
        end
        args = [1, 2, 3]
        prock = proc { puts 'foo' }
        instance.derp(*args, &prock)

        expect(instance.expected_self).to eq(instance)
        expect(instance.method_name).to eq(:derp)
        expect(instance.args).to eq(args)
        expect(instance.block).to eq(prock)
      end
    end
  end
end
