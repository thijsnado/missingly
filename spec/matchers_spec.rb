# frozen_string_literal: true

module Missingly
  describe Matchers do
    describe '#handle_missingly' do
      it 'can be used to override previous missingly with same matcher' do
        klass = Class.new do
          include Missingly::Matchers

          handle_missingly(/foo/) do |*_args|
            'foo'
          end

          handle_missingly(/foo/) do |*_args|
            'bar'
          end
        end

        expect(klass.new.foo).to eq('bar')

        another_klass = Class.new do
          include Missingly::Matchers

          handle_missingly(/foo/) do |*_args|
            'foo'
          end
        end

        another_klass.new.foo

        another_klass.module_eval do
          handle_missingly(/foo/) do |*_args|
            'bar'
          end
        end

        expect(another_klass.new.foo).to eq('bar')
      end
    end
  end
end
