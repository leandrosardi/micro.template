module BlackStack
    module MicroDfylAppending
        class LeadHypeRow < Sequel::Model(:leadhype_row)
            many_to_one :order, :class=>:'BlackStack::MicroDfylAppending::Order', :key=>:id_order
        end # class LeadHypeRow
    end # module MicroDfylAppending
end # module BlackStack