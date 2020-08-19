require "i18n"

module CustomSort
  class MagicNew
    attr_accessor :query_name, :recency_key, :options

    def initialize(query_name:, **options)
        @query_name = query_name
        @options = options

        @recency_key = options[:recency_key] ? options[:recency_key].to_i : 2
    end

    def self.validate_period(period, permit)
      permitted_periods = ((permit || CustomSort::FIELDS).map(&:to_sym) & CustomSort::FIELDS).map(&:to_s)
      raise ArgumentError, "Unpermitted period" unless permitted_periods.include?(period.to_s)
    end

    class Enumerable < MagicNew
      def customsort_by(enum, &_block)
        group = enum.group_by do |v|
          v = yield(v)
          raise ArgumentError, "Not a time" unless v.respond_to?(:to_time)
          series_builder.round_time(v)
        end
        series_builder.generate(group, default_value: [], series_default: false)
      end

      def self.customsort_by(enum, query_name, options, &block)
        CustomSort::MagicNew::Enumerable.new(query_name: query_name, **options).group_by(enum, &block)
      end
    end

    class Relation < MagicNew
      def initialize(**options)
        super(**options.reject { |k, _| [:default_value, :carry_forward, :last, :current].include?(k) })
        @options = options
      end

      def self.generate_relation(relation, field: nil, **options)
        magic = CustomSort::MagicNew::Relation.new(**options)

        # generate ActiveRecord relation
        relation =
          RelationBuilder.new(
            relation,
            column: field,
            query_name: magic.query_name,
            recency_key: magic.recency_key
          ).generate

        relation

      end

      # allow any options to keep flexible for future
      def self.process_result(relation, result, **options)
        relation.customsort_values.reverse.each do |gv|
          result = gv.perform(relation, result, default_value: options[:default_value])
        end
        result
      end
    end
  end
end