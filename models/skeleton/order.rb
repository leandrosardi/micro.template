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

            def submit(l=nil)
                l = BlackStack::DummyLogger.new(nil) if l.nil?
                # login LeadHype
                email = LEADHYPE_EMAIL
                password = LEADHYPE_PASSWORD
                o = self
                # login
                l.logs "Logging in LeadHype as #{email}... "
                bot = BlackStack::Bots::LeadHype.new(email, password)
                bot.login
                l.done
                # check if order already submitted
                n = bot.sales_navigator_jobs(o.id).size
                if n>0
                    l.logf "already submitted".yellow
                else
                    bot.submit(o.id, o.url)
                    l.logf "submitted".green
                end
            end

            # check the status of the order in leadhype
            def check(l=nil)
                l = BlackStack::DummyLogger.new(nil) if l.nil?
                # login LeadHype
                email = LEADHYPE_EMAIL
                password = LEADHYPE_PASSWORD
                o = self
                success = false
                # login
                l.logs "Logging in LeadHype as #{email}... "
                bot = BlackStack::Bots::LeadHype.new(email, password)
                bot.login
                l.done
                # check if order already submitted, and completed
                a = bot.sales_navigator_jobs(o.id)
                if a.size == 0
                    raise "job not found"
                elsif a.size > 1
                    raise "multiple jobs found"
                elsif (
                    a[0][:status] != BlackStack::Bots::LeadHype::STATUS_COMPLETED &&
                    a[0][:status] != BlackStack::Bots::LeadHype::STATUS_ERROR
                )
                    # update lh job status
                    o.leadhype_job_status = a[0][:status]
                    o.save
                    # close the log
                    l.logf a[0][:status].yellow
                else
                    # track of the job was completed successfully
                    success = (a[0][:status] == BlackStack::Bots::LeadHype::STATUS_COMPLETED)
                    # update lh job status
                    o.leadhype_job_status = a[0][:status]
                    o.save
                    if success
                        # download CSV file
                        bot.download(o.id)
                        # ingest the CSV file
                        o.leadhype_ingest
                    end
                    l.logf success ? "ingested".green : "error".red
                end
            end


            # find the CSV file in the local filesystem, parse it, and create rows in the table dfyl_leadhype_row
            def ingest(l=nil)
                l = BlackStack::DummyLogger.new(nil) if l.nil?
                tempfile = "/tmp/#{self.id.to_guid}.csv"

                l.logs "Truncating again the temp table... "
                command = "truncate table eml_upload_leads_row_aux;"
                DB.execute(command)
                l.done

                # import to the userfile of CRDB
                l.logs "Upload CSV to CRDB Cloud... "
                command = "cockroach userfile upload #{tempfile} --url \"#{BlackStack::CRDB.connection_string_2}\""
                res = `#{command}`
                l.logf res

                # delete temp file
                l.logs "Delete temp file... "
                command = "rm #{tempfile}"
                res = `#{command}`
                l.logf res

                # truncate the temp table
                l.logs "Trucating temp table... "
                command = "truncate table leadhype_row_aux;"
                DB.execute(command)
                l.done

                # import all files to the database,
                # making the 3 queries below in a single transaction.
                # update the id, id_file of all lines
                l.logs "Ingesting file to temp table... "
                command = "import into leadhype_row_aux (\"line\") DELIMITED data('userfile:///#{self.id.to_guid}.csv') with fields_terminated_by=E'', fields_enclosed_by='';"
                DB.execute(command)
                l.done

                l.logs "Updating the temp table... "
                command = "update leadhype_row_aux set id=gen_random_uuid(), id_order='#{self.id.to_sql}';"
                DB.execute(command)
                l.done

                l.logs "Map temp table to final table... "
                command = "insert into dfyl_leadhype_row (id, id_order, \"line\") select id, id_order, \"line\" from leadhype_row_aux on conflict do nothing;"
                DB.execute(command)
                l.done
            end # leadhype_ingest

        end # class Order
    end # module MicroDfylAppending
end # module BlackStack