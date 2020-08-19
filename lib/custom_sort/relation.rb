require "active_support/concern"

module CustomSort
  module Relation
    extend ActiveSupport::Concern

    included do
      attr_accessor :customsort_values
    end

    def calculate(*args, &block)
      default_value = [:count, :sum].include?(args[0]) ? 0 : nil
      CustomSort.process_result(self, super, default_value: default_value)
    end
  end
end