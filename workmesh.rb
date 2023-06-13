# required gems
require 'colorize'
require 'pg'
require 'sequel'
require 'bcrypt'
require 'mail'
require 'pry'
require 'cgi'
require 'erb'
require 'uri'
require 'nokogiri'
require 'fileutils'
require 'rack/contrib/try_static' # this is to manage many public folders

# basic blackstack libraries
require 'blackstack-core'
require 'simple_command_line_parser'
require 'simple_cloud_logging'
require 'blackstack-deployer'
require 'pampa'

# additional blackstack libraries for this project
require 'leadhypebot'

# Default login and signup screens.
# 
DEFAULT_LOGIN = '/login'
DEFAULT_SIGNUP = '/leads/signup'

# Is this a development environment?
# Many features below will be enabled or disabled based on this 
# flag.
#
# Check a file `.sandbox` to decide if it is sandbox or not. 
# This way I can work with 1 single config file for both: dev and 
# production environment. 
#
# If `SANDBOX` is off (your are working on production).
#
SANDBOX = File.exists?('/home/leandro/code/mysaas/.sandbox')

# return a postgresql uuid
def guid()
    BlackStack::CRDB::guid
end
            
# return current datetime with format `YYYY-MM-DD HH:MM:SS`
def now()
    BlackStack::CRDB::now
end