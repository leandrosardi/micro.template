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

-- verification
alter table leadhype_row add column if not exists verify_reservation_id varchar(500) NULL;
alter table leadhype_row add column if not exists verify_reservation_time timestamp NULL;
alter table leadhype_row add column if not exists verify_reservation_times int8 NULL;
alter table leadhype_row add column if not exists verify_start_time timestamp NULL;
alter table leadhype_row add column if not exists verify_end_time timestamp NULL;
alter table leadhype_row add column if not exists verify_success bool NULL;
alter table leadhype_row add column if not exists verify_error_description varchar(8000) NULL;

-- push-back
alter table leadhype_row add column if not exists pushback_reservation_id varchar(500) NULL;
alter table leadhype_row add column if not exists pushback_reservation_time timestamp NULL;
alter table leadhype_row add column if not exists pushback_reservation_times int8 NULL;
alter table leadhype_row add column if not exists pushback_start_time timestamp NULL;
alter table leadhype_row add column if not exists pushback_end_time timestamp NULL;
alter table leadhype_row add column if not exists pushback_success bool NULL;
alter table leadhype_row add column if not exists pushback_error_description varchar(8000) NULL;
