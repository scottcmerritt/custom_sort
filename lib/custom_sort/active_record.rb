require "active_record"
require "custom_sort/query_methods"
require "custom_sort/relation"

ActiveRecord::Base.extend(CustomSort::QueryMethods)
ActiveRecord::Relation.include(CustomSort::Relation)