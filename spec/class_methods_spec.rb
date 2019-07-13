# frozen_string_literal: true

require 'spec_helper'

describe Missingly::Matchers do
  let(:search_class) do
    Class.new do
      include Missingly::Matchers

      handle_missingly [:find_by_name], class_method: true do |_method_name, *args|
        return { foo: args.first || 'bar' }
      end

      handle_missingly(/^find_all_by_(\w+)$/, class_method: true) do |matches, *_args|
        return matches
      end
    end
  end

  let(:delegation_test) do
    Class.new(search_class) do
      handle_missingly [:find_by_foo], to: :proxy, class_method: true

      def self.proxy
        OpenStruct.new(find_by_foo: 'foo')
      end
    end
  end

  it 'should not break normal method_missing' do
    expect(search_class.new.respond_to?('foo_bar_widget')).to eq(false)
  end

  it 'should allow you to define class methods' do
    expect(search_class.respond_to?('find_by_name')).to eq(true)
    expect(search_class.respond_to?('find_all_by_name')).to eq(true)
    expect(search_class.find_all_by_name).to be_a MatchData
    expect(search_class.find_by_name).to be_a Hash
  end

  it 'should support delegation matchers' do
    expect(delegation_test.respond_to?('find_by_foo')).to eq(true)
    expect(delegation_test.find_by_foo).to eq('foo')
  end

  it 'should not make class methods available to instances' do
    expect(search_class.new.respond_to?('find_by_name')).to eq(false)
    expect { search_class.new.find_by_name('foo') }.to raise_exception(NameError)
  end

  it 'should work through inheritence' do
    expect(delegation_test.respond_to?('find_all_by_name')).to eq(true)
    expect(delegation_test.find_all_by_name).to be_a MatchData
  end

  it 'should accept method arguments' do
    expect(search_class.find_by_name('arg_test')).to eq(foo: 'arg_test')
  end
end
