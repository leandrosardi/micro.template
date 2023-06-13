require 'sinatra'
require 'workmesh'

# 
parser = BlackStack::SimpleCommandLineParser.new(
  :description => 'This command will launch a Sinatra-based BlackStack webserver.', 
  :configuration => [{
    :name=>'port', 
    :mandatory=>false, 
    :description=>'Listening port.', 
    :type=>BlackStack::SimpleCommandLineParser::INT,
    :default => 3000,
  }, {
    :name=>'config', 
    :mandatory=>false, 
    :description=>'Name of the configuration file.', 
    :type=>BlackStack::SimpleCommandLineParser::STRING,
    :default => 'config',
  }]
)

#
require parser.value('config')
require 'version'
DB = BlackStack::CRDB::connect

# 
puts '
__     __     ______     ______     __  __        __    __     ______     ______     __  __    
/\ \  _ \ \   /\  __ \   /\  == \   /\ \/ /       /\ "-./  \   /\  ___\   /\  ___\   /\ \_\ \   
\ \ \/ ".\ \  \ \ \/\ \  \ \  __<   \ \  _"-.     \ \ \-./\ \  \ \  __\   \ \___  \  \ \  __ \  
 \ \__/".~\_\  \ \_____\  \ \_\ \_\  \ \_\ \_\     \ \_\ \ \_\  \ \_____\  \/\_____\  \ \_\ \_\ 
  \/_/   \/_/   \/_____/   \/_/ /_/   \/_/\/_/      \/_/  \/_/   \/_____/   \/_____/   \/_/\/_/                                                                                                 

Welcome to MySaaS '+WORKMESH_VERSION.green+'.

---> '+'https://github.com/ConnectionSphere/micro.dfyl.appending'.blue+' <---

Sandbox Environment: '+(SANDBOX ? 'yes'.green : 'no'.red)+'.

'

PORT = parser.value("port")

configure { set :server, :puma }
set :bind, '0.0.0.0'
set :port, PORT
enable :sessions
enable :static

configure do
  enable :cross_origin
end  

before do
  headers 'Access-Control-Allow-Origin' => '*', 
          'Access-Control-Allow-Methods' => ['OPTIONS', 'GET', 'POST']  
end

set :protection, false

# Setting the root of views and public folders in the `~/code` folder in order to have access to extensions.
# reference: https://stackoverflow.com/questions/69028408/change-sinatra-views-directory-location
set :root,  File.dirname(__FILE__)
set :views, Proc.new { File.join(root) }

# page not found redirection
not_found do
  if !logged_in?
    redirect '/'
  else
    redirect '/404'
  end
  #redirect "/404?url=#{request.env['rack.url_scheme']}://#{request.env['HTTP_HOST']}#{CGI::escape(request.path_info)}"
end

# unhandled exception redirectiopn
error do
  max_lenght = 8000
  s = "message=#{CGI.escape(env['sinatra.error'].to_s)}&"
  s += "backtrace_size=#{CGI.escape(env['sinatra.error'].backtrace.size.to_s)}&"
  i = 0
  env['sinatra.error'].backtrace.each { |a| 
    a = "backtrace[#{i.to_s}]=#{CGI.escape(a.to_s)}&"
    and_more = "backtrace[#{i.to_s}]=..." 
    if (s+a).size > max_lenght - and_more.size
      s += and_more
      break
    else
      s += a
    end
    i += 1 
  }
  redirect "/500?#{s}"
end

# condition: api_key parameter is required too for the access points
set(:api_key) do |*roles|
  condition do
    @return_message = {}
    
    @return_message[:status] = 'success'

    # validate: the pages using the :api_key condition must work as post only.
    if request.request_method != 'POST'
      @return_message[:status] = 'Pages with an `api_key` parameter are only available for POST requests.'
      @return_message[:value] = ""
      halt @return_message.to_json
    end

    @body = JSON.parse(request.body.read)

    if !@body.has_key?('api_key')
      # libero recursos
      DB.disconnect 
      GC.start
      @return_message[:status] = "api_key is required on #{@body.to_s}"
      @return_message[:value] = ""
      halt @return_message.to_json
    end

    if !@body['api_key'].guid?
      # libero recursos
      DB.disconnect 
      GC.start
  
      @return_message[:status] = "Invalid api_key (#{@body['api_key']}))"
      @return_message[:value] = ""
      halt @return_message.to_json      
    end
    
    validation_api_key = @body['api_key'].to_guid.downcase

    if validation_api_key != API_KEY
      # libero recursos
      DB.disconnect 
      GC.start
      #     
      @return_message[:status] = 'Wrong api_key'
      @return_message[:value] = ""
      halt @return_message.to_json        
    end
  end
end

get '/404', :agent => /(.*)/ do
  erb :'views/404', :layout => :'/views/layouts/public'
end

get '/500', :agent => /(.*)/ do
  erb :'views/500', :layout => :'/views/layouts/public'
end
