# frozen_string_literal: true

require 'spec_helper'

module Missingly
  describe Matchers do
    let(:find_by_matcher) do
      FindByMatcher = Class.new(Missingly::RegexBlockMatcher) do
        attr_reader :method_block, :options

        def initialize(regex, options, block)
          @regex = regex
          @options = options
          @method_block = block
        end

        def setup_method_name_args(method_name)
          matches = regex.match(method_name)
          matches[1].split('_and_').map(&:to_sym)
        end
      end
    end

    let(:our_class) do
      find_by_matcher
      Class.new do
        include Missingly::Matchers
        attr_reader :hashes

        def initialize(hashes)
          @hashes = hashes
        end

        handle_missingly(/^find_by_(\w+)$/, with: FindByMatcher) do |fields, *args|
          hashes.find do |hash|
            fields.inject(true) do |fields_match, field|
              index_of_field = fields.index(field)
              arg_for_field = args[index_of_field]

              fields_match &&= hash[field.to_sym] == arg_for_field
              break false unless fields_match

              true
            end
          end
        end
      end
    end

    let(:our_instance) do
      hashes = [
        { first_name: 'Bob', last_name: 'Dole' },
        { first_name: 'Bill', last_name: 'Clinton' },
        { first_name: 'George', last_name: 'Bush' }
      ]
      our_class.new(hashes)
    end

    it 'should allow us to define custom matchers' do
      expect(our_instance.find_by_first_name_and_last_name('Bill', 'Douglas')).to be_nil
      expect(our_instance.find_by_first_name_and_last_name('Bill', 'Clinton')).to eq(first_name: 'Bill', last_name: 'Clinton')
    end
  end
end
