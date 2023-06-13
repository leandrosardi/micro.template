module BlackStack
    module MicroDfylAppending
        class LeadHypeRow < Sequel::Model(:leadhype_row)
            many_to_one :order, :class=>:'BlackStack::MicroDfylAppending::Order', :key=>:id_order

            LEADS_PER_PAGE = 25

            # create a hash descriptor of a lead and merge it into the database
            # return the lead object.
            def import(l=nil)
                l = BlackStack::DummyLogger.new(nil) if l.nil?
                pagesize = BlackStack::MicroDfylAppending::Order::LEADS_PER_PAGE
                
                row = CSV.parse(self.line)[0]
                self.page_number = ((row[0].to_f-1.to_f) / pagesize.to_f).floor + 1
                self.email1 = row[1].to_s
                self.email2 = row[2].to_s
                self.first_name = row[3].to_s
                self.middle_name = row[4].to_s
                self.last_name = row[5].to_s
                self.linkedin_url = row[6].to_s
                self.job_position = row[7].to_s
                self.company_name = row[8].to_s
                self.company_url = row[9].to_s
                #curl = row[10].to_s.empty? ? '' : "https://www.linkedin.com/company/#{row[10].to_s}}"
                self.location = row[11].to_s

                # remove duplicated emails
                self.email1 = self.email1.downcase.strip
                self.email2 = self.email2.downcase.strip
                self.email2 = nil if self.email2==self.email1
                    
                # update
                self.save
            end # def import

            def verify(l=nil)
                l = BlackStack::DummyLogger.new(nil) if l.nil?
                verified1 = false
                verified2 = false
                res1 = nil
                res2 = nil

                # verify the first email
                if self.email1
                    res1 = BlackStack::Appending.debounce_verify(self.email1)
                end

                # verify the second email only if the first one has not been verified
                if self.email2 && !verified1
                    res2 = BlackStack::Appending.debounce_verify(self.email2)
                end        
        
                # update
                self.res1 = res1
                self.res2 = res2
                self.save
            end # def verify

            def pushback(l=nil)
                l = BlackStack::DummyLogger.new(nil) if l.nil?

                # build the hash descriptor of the lead
                l.logs 'Build lead descriptor... '
                h = {
                    'name' => "#{self.first_name} #{self.last_name}",
                    'position' => self.job_position,   
                    'company' => {},
                    'location' => self.location,
                    'datas' => [],       
                }

                h['company'] = {
                    'name' => self.company_name,
                    'url' => self.company_url,
                } if !self.company_name.to_s.empty?

                h['datas'] << {
                    'type' => 20,
                    'value' => self.email1,
                    'db_status' => self.db_result1,
                } if !self.email1.to_s.empty?
                    
                h['datas'] << {
                    'type' => 20,
                    'value' => self.email2,
                    'db_status' => self.db_result2,
                } if !self.email2.to_s.empty?
                    
                h['datas'] << {
                    'type' => 90,
                    'value' => self.linkedin_url,
                } if !self.linkedin_url.to_s.empty?
                l.done

                # build params
                l.logs 'Build params... '
                params = {
                    'id_order' => self.id,
                    'lead' => h.to_json,
                }
                l.done

                # call the API
                l.logs 'Call the API... '
                begin
                    res = BlackStack::Netting::call_post(url, params)
                    parsed = JSON.parse(res.body)
                    raise parsed['status'] if parsed['status']!='success'
                    l.logf parsed.to_s.green
                rescue Errno::ECONNREFUSED => e
                    l.logf "Error: #{e.message}".red
                    raise "Errno::ECONNREFUSED:" + e.message
                rescue => e2
                    l.logf "Error: #{e.message}".red
                    raise "Exception:" + e2.message
                end
            end # def pushback

        end # class LeadHypeRow
    end # module MicroDfylAppending
end # module BlackStack