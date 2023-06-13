# WorkMesh Configuration File.
# Author: Leandro D. Sardi.
# Date: Jun-2023.
#
# Never push the file to the repository.
# Be sure this file is always included in the .gitignore file.
#
# To save config.rb and other critical files,
# 
# use the command `backup.rb`. This will create a backup of the current
# files into a cloud storage specified by you.
#

APP_NAME = 'micro.dfyl.appending'
APP_URL = 'https://github.com/ConnectionSphere/micro.dfyl.appending'

# This is the api key to call the access points of the micro-service.
API_KEY = '118f3c32-c920-40c0-a938-22b7471f8d20'

# setting up breakpoints for backend processes.
# enabling/disabling the flag  will enable/disable the function 
BlackStack::Debugging::set({
  :allow_breakpoints => SANDBOX,
})

# DB ACCESS - KEEP IT SECRET
# Connection string to the demo database: export DATABASE_URL='postgresql://demo:<ENTER-SQL-USER-PASSWORD>@free-tier14.aws-us-east-1.cockroachlabs.cloud:26257/mysaas?sslmode=verify-full&options=--cluster%3Dmysaas-demo-6448'
BlackStack::PostgreSQL::set_db_params({ 
  :db_url => 'localhost', # always working with production database 
  :db_port => '5432', 
  :db_name => 'ms.dfyl.appending', 
  :db_user => 'blackstack', 
  :db_password => 'SantaClara123',
})

# Appending Configuration
# Used by both extensions: Enrichment and DFY-Leads.
# 
BlackStack::Appending.set({
    # what are the indexes you will use for this appending?
    :indexes => BlackStack::CSVIndexer.indexes.select { |i| i.name =~ /persona/ },
    
    # for email verification.
    # don't use HTTPS becuase SSL verification issue.
    :verifier_url => 'http://connectionsphere.com:3000/api1.0/emails/verify.json',
    :verifier_api_key => BlackStack::API.api_key,

    # funding specific data
    :email_fields => [:email, :email1, :email2],
    :phone_fields => [:phone, :phone1, :phone2],
    :company_domain_fields => [:company_domain],

    # zerobounce integration - https://zerobounce.net
    :zerobounce_api_key => '6181cab5fec640a481c05705a750564d',

    # emailverify integration - https://emaillistverify.com
    :emailverify_api_key => 'DPCM9SJXrCJYCsPdrQqxE',

    # debounce integration - https://debounce.io/
    :debounce_api_key => '6484b2ddde901',
})

# Pampa configuration
BlackStack::Pampa.set_connection_string( BlackStack::PostgreSQL.connection_string )
BlackStack::Pampa.set_log_filename('dispatcher.log')
BlackStack::Pampa.set_integrate_with_blackstack_deployer true
BlackStack::Pampa.set_config_filename 'config.rb'
BlackStack::Pampa.set_worker_filename 'worker.rb'
BlackStack::Pampa.set_working_directory '/home/leandro/code/mysaas'
BlackStack::Pampa.add_nodes(
  [
    {
        :name => 'local',
        # setup SSH connection parameters
        :net_remote_ip => '127.0.0.1',  
        :ssh_username => 'leandro', # example: root
        :ssh_port => 22,
        :ssh_password => '2404',
        # setup max number of worker processes
        :max_workers => 1,
        # git
        :git_branch => 'main',
        # name of the LAN interface
        :laninterface => 'eth0',
        # config.rb content - always using dev-environment here
        :config_rb_content => File.read(SANDBOX ? '/home/leandro/code/micro.dfyl.appending/config.rb' : '$HOME/code/micro.dfyl.appending/config.rb'),
        # deployment routine for this node
        :deployment_routine => 'deploy-mysaas',
    },
  ]
)

# TODO: return the value of pending tasks in this micro-service, for doing a load balancing.
def pending_tasks
  0
end

# Pampa: order.submit
# Pampa: order.ingest

# Pampa: leadhype_row.import
BlackStack::Pampa.add_job({
  :name => 'leadhype_row.import',

  # Maximum number of tasks that a worker must have in queue.
  # Default: 5
  :queue_size => 10, 
  
  # If the number of pending tasks is higher than this threshold, 
  # more workers will be attached to this job.
  #
  # One worker can handle 100 tasks alone.
  # 
  :max_pending_tasks => 1,

  # Maximum number of workers attached to this job.
  :max_assigned_workers => 100,

  # specify the nodes or workers that will be assigned to this job.
  # default: /.*/g
  :filter_worker_id => /\.([1-9]|1[0-5])$/, # only 1 worker per server will hanlde the indexes

  # Maximum number of minutes that a task should take to process.
  # If a tasks didn't finish X minutes after it started, it is restarted and assigned to another worker.
  # Default: 15
  :max_job_duration_minutes => 5, 

  # Maximum number of times that a task can be restarted.
  # Default: 3
  :max_try_times => 3,

  # Define the tasks table: each record is a task.
  # The tasks table must have some specific fields for handling the tasks dispatching.
  :table => :leadhype_row, # Note, that we are sending a class object here
  :field_primary_key => :id,
  :field_id => :import_reservation_id,
  :field_time => :import_reservation_time, 
  :field_times => :import_reservation_times,
  :field_start_time => :import_start_time,
  :field_end_time => :import_end_time,
  :field_success => :import_success,
  :field_error_description => :import_error_description,

  # Function to execute for each task.
  :processing_function => Proc.new do |task, l, job, worker, *args|
    o = BlackStack::MicroDfylAppending::LeadHypeRow.where(:id=>task[:id]).first
    o.import
  end
}) # end of job descriptor

# Pampa: leadhype_row.verify
BlackStack::Pampa.add_job({
  :name => 'leadhype_row.verify',

  # Maximum number of tasks that a worker must have in queue.
  # Default: 5
  :queue_size => 10, 
  
  # If the number of pending tasks is higher than this threshold, 
  # more workers will be attached to this job.
  :max_pending_tasks => 1,

  # Maximum number of workers attached to this job.
  :max_assigned_workers => 100,

  # specify the nodes or workers that will be assigned to this job.
  # default: /.*/
  :filter_worker_id => /\.(1[6-9]|2[0-5])$/,

  # Maximum number of minutes that a task should take to process.
  # If a tasks didn't finish X minutes after it started, it is restarted and assigned to another worker.
  # Default: 15
  :max_job_duration_minutes => 2, 

  # Maximum number of times that a task can be restarted.
  # Default: 3
  :max_try_times => 3,

  # Define the tasks table: each record is a task.
  # The tasks table must have some specific fields for handling the tasks dispatching.
  :table => :leadhype_row, # Note, that we are sending a class object here
  :field_primary_key => :id,
  :field_id => :verify_reservation_id,
  :field_time => :verify_reservation_time, 
  :field_times => :verify_reservation_times,
  :field_start_time => :verify_start_time,
  :field_end_time => :verify_end_time,
  :field_success => :verify_success,
  :field_error_description => :verify_error_description,

  # Function to execute for each task.
  :processing_function => Proc.new do |task, l, job, worker, *args|
    o = BlackStack::MicroDfylAppending::LeadHypeRow.where(:id=>task[:id]).first
    o.verify
  end
}) # end of job descriptor

# Pampa: leadhype_row.pushback
BlackStack::Pampa.add_job({
  :name => 'leadhype_row.pushback',

  # Maximum number of tasks that a worker must have in queue.
  # Default: 5
  :queue_size => 10, 
  
  # If the number of pending tasks is higher than this threshold, 
  # more workers will be attached to this job.
  :max_pending_tasks => 1,

  # Maximum number of workers attached to this job.
  :max_assigned_workers => 100,

  # specify the nodes or workers that will be assigned to this job.
  # default: /.*/
  :filter_worker_id => /\.(1[6-9]|2[0-5])$/,

  # Maximum number of minutes that a task should take to process.
  # If a tasks didn't finish X minutes after it started, it is restarted and assigned to another worker.
  # Default: 15
  :max_job_duration_minutes => 2, 

  # Maximum number of times that a task can be restarted.
  # Default: 3
  :max_try_times => 3,

  # Define the tasks table: each record is a task.
  # The tasks table must have some specific fields for handling the tasks dispatching.
  :table => :leadhype_row, # Note, that we are sending a class object here
  :field_primary_key => :id,
  :field_id => :pushback_reservation_id,
  :field_time => :pushback_reservation_time, 
  :field_times => :pushback_reservation_times,
  :field_start_time => :pushback_start_time,
  :field_end_time => :pushback_end_time,
  :field_success => :pushback_success,
  :field_error_description => :pushback_error_description,

  # Function to execute for each task.
  :processing_function => Proc.new do |task, l, job, worker, *args|
    o = BlackStack::MicroDfylAppending::LeadHypeRow.where(:id=>task[:id]).first
    o.pushback
  end
}) # end of job descriptor