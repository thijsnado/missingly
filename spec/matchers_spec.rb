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

    context "calling method with missingly hook" do
      it "should only respond to methods that match regular expression passed to missingly" do
        instance = our_class.new
        instance.respond_to?("find_by_id").should be_true
        instance.respond_to?("fluffy_buffy_bunnies").should be_false
      end
    end
  end
end
