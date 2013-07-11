require 'spec_helper'

module Missingly
  describe Matchers do
    let(:find_by_matcher) do
      FindByMatcher = Class.new(Missingly::BlockMatcher) do
        attr_reader :method_block

        REGEX = /^find_by_(\w+)$/

        def initialize(options, block)
          @method_block = block
        end

        def should_respond_to?(_, method_name)
          REGEX.match(method_name)
        end

        def setup_method_name_args(method_name)
          matches = REGEX.match(method_name)
          matches[1].split("_and_").map(&:to_sym)
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

        handle_missingly FindByMatcher do |fields, *args|
          hashes.find do |hash|
            fields.inject(true) do |fields_match, field|
              index_of_field = fields.index(field)
              arg_for_field = args[index_of_field]

              fields_match = fields_match && hash[field.to_sym] == arg_for_field
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

    it "should allow us to define custom matchers" do
      our_instance.find_by_first_name_and_last_name('Bill', 'Douglas').should be_nil
      our_instance.find_by_first_name_and_last_name('Bill', 'Clinton').should == { first_name: 'Bill', last_name: 'Clinton' }
    end
  end
end
