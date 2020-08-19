module CustomSort
    module QueryMethods

        CustomSort::FIELDS.each do |query_name|
            define_method :"customsort_by_#{query_name}" do |**options|
            CustomSort::MagicNew::Relation.generate_relation(self,
            query_name: query_name.to_s,
            **options
            )
            end

        end

      def customsort(query_name, **options)
        send("customsort_by_#{query_name}", **options)
      end
      
      def customsort_by_field(query_name, permit: nil, **options)
        #CustomSort::Magic.validate_query(query_name, permit)
        send("customsort_by_#{query_name}", **options)
      end
  
    end
  end