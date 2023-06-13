module BlackStack
    module MicroDfylAppending
        class Order < Sequel::Model(:order)
            one_to_many :leadhype_rows, :class=>:'BlackStack::MicroDfylAppending::LeadHypeRow', :key=>:id_order

            TYPE_SNS = 0 # Sales Navigator Search

            # list of different types and their names
            def self.types()
                [TYPE_SNS]
            end

            def self.type_name(type)
                case type
                when TYPE_SNS
                    'Sales Navigator Search'
                end
            end
            
        end # class Order
    end # module MicroDfylAppending
end # module BlackStack