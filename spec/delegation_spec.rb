# frozen_string_literal: true

require 'spec_helper'

module Missingly
  describe Matchers do
    let(:our_class) do
      Class.new do
        include Missingly::Matchers

        attr_accessor :proxy

        handle_missingly [:derp], to: :proxy
        handle_missingly(/^find_by_(\w+)$/, to: :proxy)
      end
    end

    let(:proxy) { double }

    let(:instance) do
      i = our_class.new
      i.proxy = proxy
      i
    end

    it 'should delegate method to attribute passed to to option for arrays' do
      args = [1, 2]
      prock = proc { puts "Don't call" }

      expect(proxy).to receive(:derp).with(*args, prock)

      instance.derp(*args, *prock)
    end

    it 'should delegate method to attribute passed to to option for regexes' do
      args = [1, 2]
      prock = proc { puts "Don't call" }

      expect(proxy).to receive(:find_by_id).with(*args, prock)

      instance.find_by_id(*args, *prock)
    end
  end
end
