CREATE EXTENSION "uuid-ossp";

CREATE TABLE IF NOT EXISTS "order" (
	id uuid NOT NULL PRIMARY KEY,
	create_time timestamp NOT NULL,
	"status" bool NOT NULL,
	"type" int8 NOT NULL,
	url text NULL,
	service varchar(500) NOT NULL DEFAULT 'salesnav',
	leadhype_requested bool NOT NULL DEFAULT false,
	leadhype_csv text NULL,
	leadhype_job_status varchar(50) NULL,
	leadhype_submit_reservation_id uuid NULL,
	leadhype_submit_reservation_time timestamp NULL,
	leadhype_submit_reservation_times int8 NULL,
	leadhype_submit_start_time timestamp NULL,
	leadhype_submit_end_time timestamp NULL,
	leadhype_submit_success bool NULL,
	leadhype_submit_error_description varchar(8000) NULL,
	leadhype_ingest_reservation_id uuid NULL,
	leadhype_ingest_reservation_time timestamp NULL,
	leadhype_ingest_reservation_times int8 NULL,
	leadhype_ingest_start_time timestamp NULL,
	leadhype_ingest_end_time timestamp NULL,
	leadhype_ingest_success bool NULL,
	leadhype_ingest_error_description varchar(8000) NULL
);

CREATE TABLE IF NOT EXISTS leadhype_row (
	id uuid NOT NULL PRIMARY KEY,
	id_order uuid NOT NULL REFERENCES "order"(id),
	line varchar(8000) NOT NULL,
	import_reservation_id varchar(500) NULL,
	import_reservation_time timestamp NULL,
	import_reservation_times int8 NULL,
	import_start_time timestamp NULL,
	import_end_time timestamp NULL,
	import_success bool NULL,
	import_error_description varchar(8000) NULL
);

CREATE UNIQUE INDEX CONCURRENTLY IF NOT EXISTS uk_leadhype_row__id_order__line ON leadhype_row(id_order ASC, line ASC);

CREATE TABLE IF NOT EXISTS leadhype_row_aux (
	id uuid NULL,
	id_order uuid NULL,
	"line" varchar(8000) NOT NULL,
	rowid int8 NOT NULL --DEFAULT uuid_generate_v4()
);

--
--
-- submit pampa
--
-- available slots
create index if not exists IX_order__leadhype_submit_reservation_id__leadhype_submit_start_time on "order"(leadhype_submit_reservation_id, leadhype_submit_start_time);

-- DB[self.table.to_sym].where(self.field_id.to_sym => worker.id, self.field_start_time.to_sym => nil).all if !self.field_start_time.nil?
create index if not exists IX_order__leadhype_submit_reservation_id on "order"(leadhype_submit_reservation_id);

-- DB[self.table.to_sym].where(self.field_id.to_sym => worker.id).all if self.field_start_time.nil?
create index if not exists IX_order__leadhype_submit_start_time__leadhype_submit_reservation_id on "order"(leadhype_submit_start_time, leadhype_submit_reservation_id);

-- ds = DB[self.table.to_sym].where(self.field_id.to_sym => nil) 
-- ds = ds.filter(self.field_end_time.to_sym => nil) if !self.field_end_time.nil?  
-- ds = ds.filter(Sequel.function(:coalesce, self.field_times.to_sym, 0)=>self.max_try_times.times.to_a) if !self.field_times.nil? 
create index if not exists IX_order__leadhype_submit_reservation_id__leadhype_submit_end_time__leadhype_submit_reservation_times on "order"(leadhype_submit_reservation_id, leadhype_submit_end_time, leadhype_submit_reservation_times);

-- SELECT * 
-- FROM #{self.table.to_s} 
-- WHERE #{self.field_time.to_s} IS NOT NULL 
-- AND #{self.field_time.to_s} < CAST('#{BlackStack::Pampa.now}' AS TIMESTAMP) - INTERVAL '#{self.max_job_duration_minutes.to_i} minutes' 
-- AND #{self.field_id.to_s} IS NOT NULL 
-- AND #{self.field_end_time.to_s} IS NULL
-- AND COALESCE(#{self.field_times.to_s},0) < #{self.max_try_times.to_i}
-- LIMIT #{n}
create index if not exists IX_order__leadhype_submit_end_time__leadhype_submit_reservation_time__leadhype_submit_reservation_times__leadhype_submit_reservation_id on "order"(leadhype_submit_end_time, leadhype_submit_reservation_time, leadhype_submit_reservation_times, leadhype_submit_reservation_id);

-- def idle
create index if not exists IX_order__leadhype_submit_success__leadhype_submit_reservation_times on "order"(leadhype_submit_success, leadhype_submit_reservation_times);

-- def running
create index if not exists IX_order__leadhype_submit_end_time__leadhype_submit_start_time on "order"(leadhype_submit_end_time, leadhype_submit_start_time);

-- def failed
create index if not exists IX_order__leadhype_submit_success__leadhype_submit_reservation_times_desc on "order"(leadhype_submit_success, leadhype_submit_reservation_times desc);

-- def error_descriptions(max_tasks_to_show=25)
create index if not exists IX_order__leadhype_submit_success on "order"(leadhype_submit_success);

--
--
-- ingest pampa
--
-- available slots
create index if not exists IX_order__ingest_reservation_id__ingest_start_time on "order"(ingest_reservation_id, ingest_start_time);

-- DB[self.table.to_sym].where(self.field_id.to_sym => worker.id, self.field_start_time.to_sym => nil).all if !self.field_start_time.nil?
create index if not exists IX_order__ingest_reservation_id on "order"(ingest_reservation_id);

-- DB[self.table.to_sym].where(self.field_id.to_sym => worker.id).all if self.field_start_time.nil?
create index if not exists IX_order__ingest_start_time__ingest_reservation_id on "order"(ingest_start_time, ingest_reservation_id);

-- ds = DB[self.table.to_sym].where(self.field_id.to_sym => nil) 
-- ds = ds.filter(self.field_end_time.to_sym => nil) if !self.field_end_time.nil?  
-- ds = ds.filter(Sequel.function(:coalesce, self.field_times.to_sym, 0)=>self.max_try_times.times.to_a) if !self.field_times.nil? 
create index if not exists IX_order__ingest_reservation_id__ingest_end_time__ingest_reservation_times on "order"(ingest_reservation_id, ingest_end_time, ingest_reservation_times);

-- SELECT * 
-- FROM #{self.table.to_s} 
-- WHERE #{self.field_time.to_s} IS NOT NULL 
-- AND #{self.field_time.to_s} < CAST('#{BlackStack::Pampa.now}' AS TIMESTAMP) - INTERVAL '#{self.max_job_duration_minutes.to_i} minutes' 
-- AND #{self.field_id.to_s} IS NOT NULL 
-- AND #{self.field_end_time.to_s} IS NULL
-- AND COALESCE(#{self.field_times.to_s},0) < #{self.max_try_times.to_i}
-- LIMIT #{n}
create index if not exists IX_order__ingest_end_time__ingest_reservation_time__ingest_reservation_times__ingest_reservation_id on "order"(ingest_end_time, ingest_reservation_time, ingest_reservation_times, ingest_reservation_id);

-- def idle
create index if not exists IX_order__ingest_success__ingest_reservation_times on "order"(ingest_success, ingest_reservation_times);

-- def running
create index if not exists IX_order__ingest_end_time__ingest_start_time on "order"(ingest_end_time, ingest_start_time);

-- def failed
create index if not exists IX_order__ingest_success__ingest_reservation_times_desc on "order"(ingest_success, ingest_reservation_times desc);

-- def error_descriptions(max_tasks_to_show=25)
create index if not exists IX_order__ingest_success on "order"(ingest_success);

--
--
-- import pampa
--
-- available slots
create index if not exists IX_leadhype_row__import_reservation_id__import_start_time on leadhype_row(import_reservation_id, import_start_time);

-- DB[self.table.to_sym].where(self.field_id.to_sym => worker.id, self.field_start_time.to_sym => nil).all if !self.field_start_time.nil?
create index if not exists IX_leadhype_row__import_reservation_id on leadhype_row(import_reservation_id);

-- DB[self.table.to_sym].where(self.field_id.to_sym => worker.id).all if self.field_start_time.nil?
create index if not exists IX_leadhype_row__import_start_time__import_reservation_id on leadhype_row(import_start_time, import_reservation_id);

-- ds = DB[self.table.to_sym].where(self.field_id.to_sym => nil) 
-- ds = ds.filter(self.field_end_time.to_sym => nil) if !self.field_end_time.nil?  
-- ds = ds.filter(Sequel.function(:coalesce, self.field_times.to_sym, 0)=>self.max_try_times.times.to_a) if !self.field_times.nil? 
create index if not exists IX_leadhype_row__import_reservation_id__import_end_time__import_reservation_times on leadhype_row(import_reservation_id, import_end_time, import_reservation_times);

-- SELECT * 
-- FROM #{self.table.to_s} 
-- WHERE #{self.field_time.to_s} IS NOT NULL 
-- AND #{self.field_time.to_s} < CAST('#{BlackStack::Pampa.now}' AS TIMESTAMP) - INTERVAL '#{self.max_job_duration_minutes.to_i} minutes' 
-- AND #{self.field_id.to_s} IS NOT NULL 
-- AND #{self.field_end_time.to_s} IS NULL
-- AND COALESCE(#{self.field_times.to_s},0) < #{self.max_try_times.to_i}
-- LIMIT #{n}
create index if not exists IX_leadhype_row__import_end_time__import_reservation_time__import_reservation_times__import_reservation_id on leadhype_row(import_end_time, import_reservation_time, import_reservation_times, import_reservation_id);

-- def idle
create index if not exists IX_leadhype_row__import_success__import_reservation_times on leadhype_row(import_success, import_reservation_times);

-- def running
create index if not exists IX_leadhype_row__import_end_time__import_start_time on leadhype_row(import_end_time, import_start_time);

-- def failed
create index if not exists IX_leadhype_row__import_success__import_reservation_times_desc on leadhype_row(import_success, import_reservation_times desc);

-- def error_descriptions(max_tasks_to_show=25)
create index if not exists IX_leadhype_row__import_success on leadhype_row(import_success);

--
--
-- verification pampa
--
alter table leadhype_row add column if not exists verify_reservation_id varchar(500) NULL;
alter table leadhype_row add column if not exists verify_reservation_time timestamp NULL;
alter table leadhype_row add column if not exists verify_reservation_times int8 NULL;
alter table leadhype_row add column if not exists verify_start_time timestamp NULL;
alter table leadhype_row add column if not exists verify_end_time timestamp NULL;
alter table leadhype_row add column if not exists verify_success bool NULL;
alter table leadhype_row add column if not exists verify_error_description varchar(8000) NULL;

-- available slots
create index if not exists IX_leadhype_row__verify_reservation_id__verify_start_time on leadhype_row(verify_reservation_id, verify_start_time);

-- DB[self.table.to_sym].where(self.field_id.to_sym => worker.id, self.field_start_time.to_sym => nil).all if !self.field_start_time.nil?
create index if not exists IX_leadhype_row__verify_reservation_id on leadhype_row(verify_reservation_id);

-- DB[self.table.to_sym].where(self.field_id.to_sym => worker.id).all if self.field_start_time.nil?
create index if not exists IX_leadhype_row__verify_start_time__verify_reservation_id on leadhype_row(verify_start_time, verify_reservation_id);

-- ds = DB[self.table.to_sym].where(self.field_id.to_sym => nil) 
-- ds = ds.filter(self.field_end_time.to_sym => nil) if !self.field_end_time.nil?  
-- ds = ds.filter(Sequel.function(:coalesce, self.field_times.to_sym, 0)=>self.max_try_times.times.to_a) if !self.field_times.nil? 
create index if not exists IX_leadhype_row__verify_reservation_id__verify_end_time__verify_reservation_times on leadhype_row(verify_reservation_id, verify_end_time, verify_reservation_times);

-- SELECT * 
-- FROM #{self.table.to_s} 
-- WHERE #{self.field_time.to_s} IS NOT NULL 
-- AND #{self.field_time.to_s} < CAST('#{BlackStack::Pampa.now}' AS TIMESTAMP) - INTERVAL '#{self.max_job_duration_minutes.to_i} minutes' 
-- AND #{self.field_id.to_s} IS NOT NULL 
-- AND #{self.field_end_time.to_s} IS NULL
-- AND COALESCE(#{self.field_times.to_s},0) < #{self.max_try_times.to_i}
-- LIMIT #{n}
create index if not exists IX_leadhype_row__verify_end_time__verify_reservation_time__verify_reservation_times__verify_reservation_id on leadhype_row(verify_end_time, verify_reservation_time, verify_reservation_times, verify_reservation_id);

-- def idle
create index if not exists IX_leadhype_row__verify_success__verify_reservation_times on leadhype_row(verify_success, verify_reservation_times);

-- def running
create index if not exists IX_leadhype_row__verify_end_time__verify_start_time on leadhype_row(verify_end_time, verify_start_time);

-- def failed
create index if not exists IX_leadhype_row__verify_success__verify_reservation_times_desc on leadhype_row(verify_success, verify_reservation_times desc);

-- def error_descriptions(max_tasks_to_show=25)
create index if not exists IX_leadhype_row__verify_success on leadhype_row(verify_success);


--
--
-- push-back pampa
--
alter table leadhype_row add column if not exists pushback_reservation_id varchar(500) NULL;
alter table leadhype_row add column if not exists pushback_reservation_time timestamp NULL;
alter table leadhype_row add column if not exists pushback_reservation_times int8 NULL;
alter table leadhype_row add column if not exists pushback_start_time timestamp NULL;
alter table leadhype_row add column if not exists pushback_end_time timestamp NULL;
alter table leadhype_row add column if not exists pushback_success bool NULL;
alter table leadhype_row add column if not exists pushback_error_description varchar(8000) NULL;

-- available slots
create index if not exists IX_leadhype_row__pushback_reservation_id__pushback_start_time on leadhype_row(pushback_reservation_id, pushback_start_time);

-- DB[self.table.to_sym].where(self.field_id.to_sym => worker.id, self.field_start_time.to_sym => nil).all if !self.field_start_time.nil?
create index if not exists IX_leadhype_row__pushback_reservation_id on leadhype_row(pushback_reservation_id);

-- DB[self.table.to_sym].where(self.field_id.to_sym => worker.id).all if self.field_start_time.nil?
create index if not exists IX_leadhype_row__pushback_start_time__pushback_reservation_id on leadhype_row(pushback_start_time, pushback_reservation_id);

-- ds = DB[self.table.to_sym].where(self.field_id.to_sym => nil) 
-- ds = ds.filter(self.field_end_time.to_sym => nil) if !self.field_end_time.nil?  
-- ds = ds.filter(Sequel.function(:coalesce, self.field_times.to_sym, 0)=>self.max_try_times.times.to_a) if !self.field_times.nil? 
create index if not exists IX_leadhype_row__pushback_reservation_id__pushback_end_time__pushback_reservation_times on leadhype_row(pushback_reservation_id, pushback_end_time, pushback_reservation_times);

-- SELECT * 
-- FROM #{self.table.to_s} 
-- WHERE #{self.field_time.to_s} IS NOT NULL 
-- AND #{self.field_time.to_s} < CAST('#{BlackStack::Pampa.now}' AS TIMESTAMP) - INTERVAL '#{self.max_job_duration_minutes.to_i} minutes' 
-- AND #{self.field_id.to_s} IS NOT NULL 
-- AND #{self.field_end_time.to_s} IS NULL
-- AND COALESCE(#{self.field_times.to_s},0) < #{self.max_try_times.to_i}
-- LIMIT #{n}
create index if not exists IX_leadhype_row__pushback_end_time__pushback_reservation_time__pushback_reservation_times__pushback_reservation_id on leadhype_row(pushback_end_time, pushback_reservation_time, pushback_reservation_times, pushback_reservation_id);

-- def idle
create index if not exists IX_leadhype_row__pushback_success__pushback_reservation_times on leadhype_row(pushback_success, pushback_reservation_times);

-- def running
create index if not exists IX_leadhype_row__pushback_end_time__pushback_start_time on leadhype_row(pushback_end_time, pushback_start_time);

-- def failed
create index if not exists IX_leadhype_row__pushback_success__pushback_reservation_times_desc on leadhype_row(pushback_success, pushback_reservation_times desc);

-- def error_descriptions(max_tasks_to_show=25)
create index if not exists IX_leadhype_row__pushback_success on leadhype_row(pushback_success);

--
--
-- leadhype parsing columns
--
alter table leadhype_row add column if not exists page_number int8 null;
alter table leadhype_row add column if not exists email1 varchar(500) null;
alter table leadhype_row add column if not exists email2 varchar(500) null;
alter table leadhype_row add column if not exists first_name varchar(500) null;
alter table leadhype_row add column if not exists middle_name varchar(500) null;
alter table leadhype_row add column if not exists last_name varchar(500) null;
alter table leadhype_row add column if not exists linkedin_url varchar(8000) null;
alter table leadhype_row add column if not exists job_position varchar(500) null;
alter table leadhype_row add column if not exists company_name varchar(500) null;
alter table leadhype_row add column if not exists company_url varchar(8000) null;
alter table leadhype_row add column if not exists "location" varchar(500) null;

--
--
-- leadhype verification
--
alter table leadhype_row add column if not exists db_result1 int8 null;
alter table leadhype_row add column if not exists db_result2 int8 null;
