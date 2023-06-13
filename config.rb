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
        :ssh_password => '****',
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