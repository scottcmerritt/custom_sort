module Enumerable
=begin
    CustomSort::FIELDS.each do |period|
      define_method :"group_by_#{period}" do |*args, **options, &block|
        if block
          raise ArgumentError, "wrong number of arguments (given #{args.size}, expected 0)" if args.any?
          CustomSort::Magic::Enumerable.group_by(self, period, options, &block)
        elsif respond_to?(:scoping)
          scoping { @klass.group_by_period(period, *args, **options, &block) }
        else
          raise ArgumentError, "no block given"
        end
      end
    end
  
    def group_by_period(period, *args, **options, &block)
      if block || !respond_to?(:scoping)
        raise ArgumentError, "wrong number of arguments (given #{args.size + 1}, expected 1)" if args.any?
  
        Groupdate::Magic.validate_period(period, options.delete(:permit))
        send("group_by_#{period}", **options, &block)
      else
        scoping { @klass.group_by_period(period, *args, **options, &block) }
      end
    end
=end
CustomSort::FIELDS.each do |query_name|
    define_method :"customsort_by_#{query_name}" do |*args, **options, &block|
      if block
        raise ArgumentError, "wrong number of arguments (given #{args.size}, expected 0)" if args.any?
        CustomSort::Magic::Enumerable.customsort_by(self, query_name, options, &block)
      elsif respond_to?(:scoping)
        scoping { @klass.customsort_by_field(query_name, *args, **options, &block) }
      else
        raise ArgumentError, "no block given"
      end
    end
  end

  def customsort_by_field(query_name, *args, **options, &block)
    if block || !respond_to?(:scoping)
      raise ArgumentError, "wrong number of arguments (given #{args.size + 1}, expected 1)" if args.any?

      #CustomSort::Magic.validate_period(period, options.delete(:permit))
      send("customsort_by_#{query_name}", **options, &block)
    else
      scoping { @klass.customsort_by_field(query_name, *args, **options, &block) }
    end
  end

  end