# dependencies
require "active_support/core_ext/module/attribute_accessors"
#require "active_support/time"

# modules
require "custom_sort/magic"
require "custom_sort/magic_new"
require "custom_sort/relation_builder"

require "custom_sort/version"


module CustomSort
  class Error < StandardError; end
  # Your code goes here...

  FIELDS = [:blended,:blended_recent,:quality,:interesting,:learned,:votes,:nofeedback,:nojoin] # [:second, :minute, :hour, :day, :week, :month, :quarter, :year, :day_of_week, :hour_of_day, :minute_of_hour, :day_of_month, :day_of_year, :month_of_year]
  METHODS = FIELDS.map { |v| :"customsort_by_#{v}" } + [:customsort_by_field]
  LAMBDA_VALUES = [-0.02445,-0.0489,-0.0990, nil]

  mattr_accessor :data_table, :blended_columns
  self.blended_columns = ["quality","interesting"]
  self.data_table = "vote_caches"

  class SortFields
    def initialize

    end
    def self.time_decay table_name
      "EXTRACT(EPOCH FROM (NOW()::timestamp - #{table_name}.created_at::timestamp))/(24*60*60)"
    end
    
    def self.time_decay_adjusted table_name, lambda_key
      lambda_val = CustomSort::LAMBDA_VALUES[lambda_key]
      time_decay_query = CustomSort::SortFields.time_decay(table_name)
      lambda_val.nil? ? "1" : "exp(#{time_decay_query}*#{lambda_val})"
    end
  end

  # api for gems like ActiveMedian or Kaminari
  def self.process_result(relation, result, **options)
    if relation.customsort_values
      result = CustomSort::Magic::Relation.process_result(relation, result, **options)
    end
    result
  end

end

require "custom_sort/enumerable"

ActiveSupport.on_load(:active_record) do
  require "custom_sort/active_record"
end