# WorkMesh Configuration File.
# Author: Leandro D. Sardi.
# Date: Jun-2023.
#
# Never push the file to the repository.
# Be sure this file is always included in the .gitignore file.
#
# To save config.rb and other critical files like  and  files,
# use the command . This will create a backup of the current
# files into a cloud storage specified by you.
#

# setting up breakpoints for backend processes.
# enabling/disabling the flag  will enable/disable the function 
BlackStack::Debugging::set({
  :allow_breakpoints => SANDBOX,
})

# DB ACCESS - KEEP IT SECRET
# Connection string to the demo database: export DATABASE_URL='postgresql://demo:<ENTER-SQL-USER-PASSWORD>@free-tier14.aws-us-east-1.cockroachlabs.cloud:26257/mysaas?sslmode=verify-full&options=--cluster%3Dmysaas-demo-6448'
BlackStack::CRDB::set_db_params({ 
  :db_url => 'free-tier14.aws-us-east-1.cockroachlabs.cloud', # always working with production database 
  :db_port => '26257', 
  :db_cluster => 'blackstack-4545', # this parameter is optional. Use this when using CRDB serverless.
  :db_name => 'blackstack', 
  :db_user => 'blackstack', 
  :db_password => 'sCOcdW94_NTJ8C6Swq6APA',
})

# Setup connection to the API, in order get bots requesting and pushing data to the database.
# TODO: write your API-Key here. Refer to this article about how to create your API key:
# https://sites.google.com/expandedventure.com/knowledge/
#
# TODO: Switch back to HTTPS when the emails.leads.uplaod.ingest process is migrated to DropBox for elastic storage.
# 
BlackStack::API::set_api_url({
  # IMPORTANT: It is strongly recommended that you 
  # use the api_key of an account with prisma role, 
  # and assigned to the central division too.
  :api_key => '118f3c32-c920-40c0-a938-22b7471f8d20', 
  # IMPORTANT: It is stringly recommended that you 
  # write the URL of the central division here. 
  :api_protocol => SANDBOX ? 'http' : 'https',
  # IMPORTANT: Even if you are running process in our LAN, 
  # don't write a LAN IP here, since bots are designed to
  # run anywhere worldwide.
  #
  # IMPORTANT: This is the only web-node where files are 
  # being stored. Never change this IP by the TLD.
  # References: 
  # - https://github.com/leandrosardi/leads/issues/110
  # - https://github.com/leandrosardi/emails/issues/142
  # 
  :api_domain => SANDBOX ? '127.0.0.1' : '54.157.239.98', 
  :api_port => SANDBOX ? '3000' : '443',
  :api_less_secure_port => '3000',
})

# Pampa configuration
BlackStack::Pampa.set_connection_string( BlackStack::CRDB.connection_string )
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
        :config_rb_content => File.read(SANDBOX ? '/home/leandro/code/mysaas/config.rb' : '$HOME/code/mysaas/config.rb'),
        # deployment routine for this node
        :deployment_routine => 'deploy-mysaas',
    },
  ]
)